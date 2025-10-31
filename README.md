# Grant-FullControl

A PowerShell script to grant Full Control permissions to all existing users/groups on a specified folder and all its contents recursively.

## Overview

This script automates the process of granting Full Control permissions to all users and groups that already have permissions on a target folder. It applies these permissions recursively to the folder and all its subdirectories and files.

## Features

- ✅ Grants Full Control permissions to all existing users/groups
- ✅ Applies permissions recursively to all subdirectories and files
- ✅ Default target: `C:\Micros` folder
- ✅ Customizable folder path via parameter
- ✅ Administrator privilege verification
- ✅ Path validation
- ✅ Comprehensive error handling
- ✅ Detailed progress output and summary

## Requirements

- Windows PowerShell 5.1 or later
- Administrator privileges
- Target folder must exist

## Usage

### Basic Usage (Default Path)

Run PowerShell as Administrator and execute:

```powershell
.\Grant-FullControl.ps1
```

This will grant Full Control permissions to all existing users/groups on the `C:\Micros` folder.

### Custom Path

To target a different folder:

```powershell
.\Grant-FullControl.ps1 -Path "C:\MyFolder"
```

### Get Help

```powershell
Get-Help .\Grant-FullControl.ps1 -Full
```

## How It Works

1. **Administrator Check**: Verifies the script is running with Administrator privileges
2. **Path Validation**: Confirms the target folder exists
3. **ACL Enumeration**: Retrieves all existing users/groups with permissions on the folder
4. **Permission Grant**: Applies Full Control permissions to each identity
5. **Recursive Application**: Permissions automatically propagate to all subdirectories and files via inheritance flags
6. **Summary Report**: Displays the results of the operation

## Example Output

```
========================================
Grant Full Control Permissions Script
========================================

Target Path: C:\Micros

Step 1: Retrieving existing ACL entries...

Found 3 unique user(s)/group(s) with existing permissions:
  - BUILTIN\Administrators
  - NT AUTHORITY\SYSTEM
  - DOMAIN\Users

Step 2: Granting Full Control permissions...
  [SUCCESS] Granted Full Control to: BUILTIN\Administrators
  [SUCCESS] Granted Full Control to: NT AUTHORITY\SYSTEM
  [SUCCESS] Granted Full Control to: DOMAIN\Users

========================================
Summary:
========================================
Total identities processed: 3
Successfully granted Full Control: 3

Full Control permissions have been applied to:
  C:\Micros (and all subdirectories/files recursively)

[COMPLETED] Operation finished successfully!
```

## Security Considerations

- This script requires Administrator privileges to modify ACLs
- The script only grants permissions to users/groups that already have some level of access
- Permissions are applied with inheritance flags (`ContainerInherit,ObjectInherit`) to ensure recursive application
- Review existing permissions before running to understand which identities will receive Full Control

## Troubleshooting

### "This script requires Administrator privileges"
- Right-click PowerShell and select "Run as Administrator"

### "The specified path does not exist"
- Verify the folder path is correct and exists
- Check for typos in the path

### Permission Denied Errors
- Ensure you have sufficient privileges on the target folder
- Check if the folder is locked by another process
- Verify you're running as Administrator

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.