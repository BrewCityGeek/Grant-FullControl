# Grant-FullControl Script - Silent Mode Support

This PowerShell script has been updated to support silent operation for scheduled tasks.

## Parameters

- **`-FolderPath`**: Path to the folder to modify (default: "C:\Micros")
- **`-Silent`**: Run without any console output
- **`-LogFile`**: Specify a log file path for output (optional)
- **`-Force`**: Skip confirmation prompt

## Usage Examples

### Interactive Mode (Default)
```powershell
.\Grant-FullControl.ps1
```

### Silent Mode with Logging
```powershell
.\Grant-FullControl.ps1 -Silent -Force -LogFile "C:\logs\permissions.log"
```

### Custom Folder Path
```powershell
.\Grant-FullControl.ps1 -FolderPath "C:\MyFolder" -Silent -Force
```

### Using the Batch File for Scheduled Tasks
```cmd
Run-Silent.bat
```

## Scheduled Task Setup

1. **Using the Batch File (Recommended)**:
   - Use `Run-Silent.bat` as the program to run
   - This will run completely silently with logging

2. **Direct PowerShell Execution**:
   - Program: `powershell.exe`
   - Arguments: `-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\scripts\Grant-FullControl\Grant-FullControl.ps1" -Silent -Force -LogFile "C:\logs\permissions.log"`

## Exit Codes

- **0**: Success
- **1**: Error occurred (folder not found, permission errors, etc.)

## Logging

When using the `-LogFile` parameter, the script will write timestamped entries including:
- INFO: Normal operation messages
- WARN: Non-critical warnings
- ERROR: Critical errors

Example log entry:
```
[2025-10-31 14:30:15] [INFO] Modifying permissions for: C:\Micros
[2025-10-31 14:30:16] [INFO] ✓ Granted Full Control to: BUILTIN\Users
[2025-10-31 14:30:17] [WARN] Failed to set permissions for some_user : Access denied
```

## Administrator Requirements

The script still requires Administrator privileges to modify folder permissions. Ensure your scheduled task is configured to run with appropriate elevated privileges.