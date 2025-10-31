<#
.SYNOPSIS
    Grants Full Control permissions to all existing users/groups on a specified folder and all its contents recursively.

.DESCRIPTION
    This script enumerates all existing users and groups that have permissions on the specified folder,
    and grants them Full Control permissions on the folder and all its contents recursively.

.PARAMETER Path
    The path to the folder where Full Control permissions will be granted.
    Default is "C:\Micros"

.EXAMPLE
    .\Grant-FullControl.ps1
    Grants Full Control to all existing users/groups on C:\Micros

.EXAMPLE
    .\Grant-FullControl.ps1 -Path "C:\MyFolder"
    Grants Full Control to all existing users/groups on C:\MyFolder

.NOTES
    This script requires Administrator privileges to modify ACLs.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\Micros"
)

# Function to check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to grant Full Control to a specific identity
function Grant-FullControl {
    param(
        [string]$FolderPath,
        [string]$Identity
    )
    
    try {
        # Get the current ACL
        $acl = Get-Acl -Path $FolderPath
        
        # Create a new access rule for Full Control
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $Identity,
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        
        # Add the access rule to the ACL
        $acl.SetAccessRule($accessRule)
        
        # Apply the modified ACL
        Set-Acl -Path $FolderPath -AclObject $acl
        
        Write-Host "  [SUCCESS] Granted Full Control to: $Identity" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "  [FAILED] Could not grant Full Control to '$Identity': $($_.Exception.Message)"
        return $false
    }
}

# Main script execution
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Grant Full Control Permissions Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if running as Administrator
if (-not (Test-Administrator)) {
    Write-Host "[ERROR] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again.`n" -ForegroundColor Yellow
    exit 1
}

# Verify the path exists
if (-not (Test-Path -Path $Path)) {
    Write-Host "[ERROR] The specified path does not exist: $Path" -ForegroundColor Red
    Write-Host "Please verify the path and try again.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "Target Path: $Path" -ForegroundColor Yellow
Write-Host "`nStep 1: Retrieving existing ACL entries..." -ForegroundColor Cyan

try {
    # Get the current ACL
    $acl = Get-Acl -Path $Path
    
    # Get all existing access rules (users and groups with permissions)
    # First, try to get explicit (non-inherited) permissions
    $existingIdentities = $acl.Access | 
        Where-Object { $_.IsInherited -eq $false } | 
        Select-Object -ExpandProperty IdentityReference -Unique
    
    # If no explicit permissions found, include inherited ones
    # This ensures we can grant permissions even on folders that only have inherited ACLs
    if ($existingIdentities.Count -eq 0) {
        Write-Host "`n[WARNING] No explicit (non-inherited) permissions found on the folder." -ForegroundColor Yellow
        Write-Host "Including inherited permissions to ensure Full Control can be granted..." -ForegroundColor Yellow
        
        $existingIdentities = $acl.Access | 
            Select-Object -ExpandProperty IdentityReference -Unique
    }
    
    Write-Host "`nFound $($existingIdentities.Count) unique user(s)/group(s) with existing permissions:" -ForegroundColor Green
    
    foreach ($identity in $existingIdentities) {
        Write-Host "  - $($identity.Value)" -ForegroundColor White
    }
    
    Write-Host "`nStep 2: Granting Full Control permissions..." -ForegroundColor Cyan
    
    $successCount = 0
    $failCount = 0
    
    foreach ($identity in $existingIdentities) {
        if (Grant-FullControl -FolderPath $Path -Identity $identity.Value) {
            $successCount++
        }
        else {
            $failCount++
        }
    }
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total identities processed: $($existingIdentities.Count)" -ForegroundColor White
    Write-Host "Successfully granted Full Control: $successCount" -ForegroundColor Green
    if ($failCount -gt 0) {
        Write-Host "Failed: $failCount" -ForegroundColor Red
    }
    Write-Host "`nFull Control permissions have been applied to:" -ForegroundColor Green
    Write-Host "  $Path (and all subdirectories/files recursively)" -ForegroundColor White
    Write-Host "`n[COMPLETED] Operation finished successfully!`n" -ForegroundColor Green
    
    exit 0
}
catch {
    Write-Host "`n[ERROR] An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)`n" -ForegroundColor Red
    exit 1
}
