# Grant-FullControl PowerShell Script

A PowerShell script to grant Full Control permissions to all existing users/groups on the `C:\Micros` folder and all its contents recursively.

## Overview

This script analyzes the current permissions on the `C:\Micros` folder and grants **Full Control** permissions to all currently assigned users and groups. It applies these permissions recursively to all subfolders and files within the directory structure.

## Features

- ✅ **Safe Operation**: Shows current permissions before making changes
- ✅ **User Confirmation**: Requires explicit confirmation before proceeding
- ✅ **Recursive Processing**: Applies permissions to all subfolders and files
- ✅ **Progress Tracking**: Shows progress for large directory structures
- ✅ **Error Handling**: Continues processing even if individual items fail
- ✅ **Detailed Reporting**: Provides comprehensive status updates
- ✅ **Inheritance Support**: Ensures future items inherit correct permissions

## Prerequisites

- **Administrator Rights**: Must be run as Administrator
- **PowerShell 5.0+**: Compatible with Windows PowerShell and PowerShell Core
- **Existing Folder**: The `C:\Micros` folder must exist
- **Appropriate Permissions**: User must have permission to modify ACLs

## Quick Start

1. **Run as Administrator**: Right-click PowerShell and select "Run as Administrator"
2. **Navigate to Script**: `cd "c:\scripts\Grant-FullControl"`
3. **Execute Script**: `.\Grant-FullControl.ps1`
4. **Review Permissions**: Check the displayed current permissions
5. **Confirm Changes**: Type `Y` to proceed or `N` to cancel

## What It Does

1. **Validates**: Checks if `C:\Micros` folder exists
2. **Analyzes**: Displays current permissions on the folder
3. **Confirms**: Asks for user confirmation before proceeding
4. **Updates Main Folder**: Grants Full Control to all existing users/groups
5. **Processes Recursively**: Applies same permissions to all subfolders and files
6. **Reports Results**: Shows completion status and any errors

## Safety Features

- **Preview Mode**: Shows what will be changed before making changes
- **Confirmation Required**: Won't proceed without explicit user confirmation
- **Error Isolation**: Failed items don't stop the entire process
- **Inherited Permissions**: Preserves inherited permissions while updating explicit ones

## Output Example

```
Modifying permissions for: C:\Micros
This will grant Full Control to all currently assigned users and groups.
Permissions will be applied recursively to ALL subfolders and files.

Current permissions:
  BUILTIN\Administrators : FullControl (Allow)
  NT AUTHORITY\SYSTEM : FullControl (Allow)
  DOMAIN\Users : ReadAndExecute (Allow)

Do you want to grant Full Control to all these users/groups on the folder AND all its contents recursively? (Y/N): Y

Updating permissions...
  ✓ Granted Full Control to: BUILTIN\Administrators
  ✓ Granted Full Control to: NT AUTHORITY\SYSTEM
  ✓ Granted Full Control to: DOMAIN\Users

Main folder permissions updated successfully!
Applying permissions recursively to all subfolders and files...
  Processed 100 items...
  Processed 200 items...

Recursive permission update completed!
  Total items processed: 247
  Items with errors: 0

Updated permissions:
  BUILTIN\Administrators : FullControl (Allow)
  NT AUTHORITY\SYSTEM : FullControl (Allow)
  DOMAIN\Users : FullControl (Allow)

Script completed.
```

## Files

- `Grant-FullControl.ps1` - Main PowerShell script
- `README.md` - This documentation file
- `USAGE.md` - Detailed usage instructions
- `TROUBLESHOOTING.md` - Common issues and solutions

## License

This script is provided as-is for administrative purposes. Use at your own discretion and ensure you have proper backups before modifying permissions.

## Version

**Version 2.0** - Enhanced with recursive permission application

## Author

Created for Windows system administration tasks.