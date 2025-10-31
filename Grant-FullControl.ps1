# Script to grant Full Control permissions to all existing users/groups on C:\Micros
# Run as Administrator

[CmdletBinding()]
param(
    [string]$FolderPath = "C:\Micros",
    [switch]$Silent,
    [string]$LogFile = "",
    [switch]$Force
)

# Function to write output that respects Silent mode
function Write-Output {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$IsError,
        [switch]$IsWarning
    )
    
    if (-not $Silent) {
        if ($IsError) {
            Write-Error $Message
        } elseif ($IsWarning) {
            Write-Warning $Message
        } else {
            Write-Host $Message -ForegroundColor $Color
        }
    }
    
    # Log to file if specified
    if ($LogFile) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logLevel = if ($IsError) { "ERROR" } elseif ($IsWarning) { "WARN" } else { "INFO" }
        Add-Content -Path $LogFile -Value "[$timestamp] [$logLevel] $Message"
    }
}

# Check if folder exists
if (-not (Test-Path $FolderPath)) {
    Write-Output "Folder '$FolderPath' does not exist!" -IsError
    exit 1
}

Write-Output "Modifying permissions for: $FolderPath" -Color Cyan
Write-Output "This will grant Full Control to all currently assigned users and groups." -Color Yellow
Write-Output "Permissions will be applied recursively to ALL subfolders and files." -Color Yellow
Write-Output ""

# Get current ACL
try {
    $acl = Get-Acl -Path $FolderPath
    Write-Output "Current permissions:" -Color Green
    
    # Display current permissions
    foreach ($access in $acl.Access) {
        $identity = $access.IdentityReference
        $rights = $access.FileSystemRights
        $type = $access.AccessControlType
        Write-Output "  $identity : $rights ($type)" -Color Gray
    }
    
    Write-Output ""
    
    # Confirm action (skip if Force or Silent is used)
    if (-not $Force -and -not $Silent) {
        $confirm = Read-Host "Do you want to grant Full Control to all these users/groups on the folder AND all its contents recursively? (Y/N)"
        if ($confirm -notmatch '^[Yy]') {
            Write-Output "Operation cancelled." -Color Yellow
            exit 0
        }
    } elseif ($Force -or $Silent) {
        Write-Output "Proceeding automatically (Force/Silent mode)..." -Color Yellow
    }
    
    Write-Output "Updating permissions..." -Color Cyan
    
    # Create new ACL with updated permissions
    $newAcl = Get-Acl -Path $FolderPath
    
    # Clear existing explicit permissions (keep inherited ones)
    $accessRules = @($newAcl.Access | Where-Object { -not $_.IsInherited })
    
    foreach ($rule in $accessRules) {
        $newAcl.RemoveAccessRule($rule) | Out-Null
    }
    
    # Add Full Control for each unique identity
    $identities = $acl.Access | Select-Object -ExpandProperty IdentityReference -Unique
    
    foreach ($identity in $identities) {
        try {
            # Create new Full Control access rule
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity,
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            
            # Add the rule to the ACL
            $newAcl.SetAccessRule($accessRule)
            Write-Output "  ✓ Granted Full Control to: $identity" -Color Green
            
        } catch {
            Write-Output "Failed to set permissions for $identity : $($_.Exception.Message)" -IsWarning
        }
    }
    
    # Apply the new ACL to the main folder
    Set-Acl -Path $FolderPath -AclObject $newAcl
    
    Write-Output ""
    Write-Output "Main folder permissions updated successfully!" -Color Green
    
    # Apply permissions recursively to all subfolders and files
    Write-Output "Applying permissions recursively to all subfolders and files..." -Color Cyan
    
    $itemCount = 0
    $errorCount = 0
    
    Get-ChildItem -Path $FolderPath -Recurse -Force | ForEach-Object {
        $itemCount++
        try {
            # Get current ACL for this item
            $itemAcl = Get-Acl -Path $_.FullName
            
            # Clear existing explicit permissions (keep inherited ones)
            $itemAccessRules = @($itemAcl.Access | Where-Object { -not $_.IsInherited })
            
            foreach ($rule in $itemAccessRules) {
                $itemAcl.RemoveAccessRule($rule) | Out-Null
            }
            
            # Add Full Control for each identity
            foreach ($identity in $identities) {
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $identity,
                    "FullControl",
                    "ContainerInherit,ObjectInherit",
                    "None",
                    "Allow"
                )
                $itemAcl.SetAccessRule($accessRule)
            }
            
            # Apply the ACL to this item
            Set-Acl -Path $_.FullName -AclObject $itemAcl
            
            if ($itemCount % 100 -eq 0) {
                Write-Output "  Processed $itemCount items..." -Color Gray
            }
            
        } catch {
            $errorCount++
            Write-Output "Failed to set permissions for '$($_.FullName)': $($_.Exception.Message)" -IsWarning
        }
    }
    
    Write-Output ""
    Write-Output "Recursive permission update completed!" -Color Green
    Write-Output "  Total items processed: $itemCount" -Color Gray
    if ($errorCount -gt 0) {
        Write-Output "  Items with errors: $errorCount" -Color Yellow
    }
    Write-Output ""
    
    # Display updated permissions
    $updatedAcl = Get-Acl -Path $FolderPath
    Write-Output "Updated permissions:" -Color Green
    foreach ($access in $updatedAcl.Access) {
        $identity = $access.IdentityReference
        $rights = $access.FileSystemRights
        $type = $access.AccessControlType
        $inherited = if ($access.IsInherited) { " (Inherited)" } else { "" }
        Write-Output "  $identity : $rights ($type)$inherited" -Color Gray
    }
    
} catch {
    Write-Output "Failed to modify permissions: $($_.Exception.Message)" -IsError
    Write-Output "Make sure you're running this script as Administrator." -Color Yellow
    exit 1
}

Write-Output ""
Write-Output "Script completed successfully." -Color Cyan

# Exit with appropriate code
if ($errorCount -gt 0) {
    Write-Output "Script completed with $errorCount errors. Check the log for details." -Color Yellow
    exit 1
} else {
    exit 0
}