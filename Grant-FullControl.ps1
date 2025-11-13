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
function Write-Log {
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
    Write-Log "Folder '$FolderPath' does not exist!" -IsError
    exit 1
}

Write-Log "Modifying permissions for: $FolderPath" -Color Cyan
Write-Log "This will grant Full Control to all currently assigned users and groups." -Color Yellow
Write-Log "Permissions will be applied recursively to ALL subfolders and files." -Color Yellow
Write-Log ""

# Get current ACL
try {
    $acl = Get-Acl -Path $FolderPath
    Write-Log "Current permissions:" -Color Green
    
    # Display current permissions
    foreach ($access in $acl.Access) {
        $identity = $access.IdentityReference
        $rights = $access.FileSystemRights
        $type = $access.AccessControlType
        Write-Log "  $identity : $rights ($type)" -Color Gray
    }
    
    Write-Log ""
    
    # Confirm action (skip if Force or Silent is used)
    if (-not $Force -and -not $Silent) {
        $confirm = Read-Host "Do you want to grant Full Control to all these users/groups on the folder AND all its contents recursively? (Y/N)"
        if ($confirm -notmatch '^[Yy]') {
            Write-Log "Operation cancelled." -Color Yellow
            exit 0
        }
    } elseif ($Force -or $Silent) {
        Write-Log "Proceeding automatically (Force/Silent mode)..." -Color Yellow
    }
    
    Write-Log "Updating permissions..." -Color Cyan
    
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
            Write-Log "  [OK] Granted Full Control to: $identity" -Color Green
            
        } catch {
            Write-Log "Failed to set permissions for $identity : $($_.Exception.Message)" -IsWarning
        }
    }
    
    # Apply the new ACL to the main folder
    Set-Acl -Path $FolderPath -AclObject $newAcl
    
    Write-Log ""
    Write-Log "Main folder permissions updated successfully!" -Color Green
    
    # Apply permissions recursively to all subfolders and files
    Write-Log "Applying permissions recursively to all subfolders and files..." -Color Cyan
    
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
                Write-Log "  Processed $itemCount items..." -Color Gray
            }
            
        } catch {
            $errorCount++
            Write-Log "Failed to set permissions for '$($_.FullName)': $($_.Exception.Message)" -IsWarning
        }
    }
    
    Write-Log ""
    Write-Log "Recursive permission update completed!" -Color Green
    Write-Log "  Total items processed: $itemCount" -Color Gray
    if ($errorCount -gt 0) {
        Write-Log "  Items with errors: $errorCount" -Color Yellow
    }
    Write-Log ""
    
    # Display updated permissions
    $updatedAcl = Get-Acl -Path $FolderPath
    Write-Log "Updated permissions:" -Color Green
    foreach ($access in $updatedAcl.Access) {
        $identity = $access.IdentityReference
        $rights = $access.FileSystemRights
        $type = $access.AccessControlType
        $inherited = if ($access.IsInherited) { " (Inherited)" } else { "" }
        Write-Log "  $identity : $rights ($type)$inherited" -Color Gray
    }
    
} catch {
    Write-Log "Failed to modify permissions: $($_.Exception.Message)" -IsError
    Write-Log "Make sure to run this script as Administrator." -Color Yellow
    exit 1
}

Write-Log ""
Write-Log "Script completed successfully." -Color Cyan

# Exit with appropriate code
if ($errorCount -gt 0) {
    Write-Log "Script completed with $errorCount errors. Check the log for details." -Color Yellow
    exit 1
} else {
    exit 0
}
