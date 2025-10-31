# Usage Guide - Grant-FullControl Script

## Detailed Usage Instructions

### Step-by-Step Execution

#### 1. Preparation
```powershell
# Open PowerShell as Administrator
# Method 1: Right-click PowerShell icon → "Run as Administrator"
# Method 2: Windows Key + X → "Windows PowerShell (Admin)"
# Method 3: Search "PowerShell" → Right-click → "Run as Administrator"
```

#### 2. Navigate to Script Location
```powershell
cd "c:\scripts\Grant-FullControl"
```

#### 3. Verify Script Presence
```powershell
ls Grant-FullControl.ps1
```

#### 4. Execute the Script
```powershell
.\Grant-FullControl.ps1
```

### What to Expect During Execution

#### Phase 1: Initial Validation
- Script checks if `C:\Micros` folder exists
- If folder doesn't exist, script exits with error message

#### Phase 2: Permission Analysis
- Displays current permissions on `C:\Micros`
- Shows all users/groups and their current access levels
- Lists permission types (Allow/Deny) and inheritance status

#### Phase 3: User Confirmation
- Prompts for confirmation before making changes
- Clearly states that changes will be applied recursively
- Accepts `Y`, `y`, `Yes`, or `yes` to proceed
- Any other input cancels the operation

#### Phase 4: Main Folder Update
- Removes existing explicit permissions (keeps inherited ones)
- Applies Full Control to all identified users/groups
- Reports success/failure for each user/group

#### Phase 5: Recursive Processing
- Processes all subfolders and files within `C:\Micros`
- Shows progress every 100 items processed
- Handles errors gracefully without stopping the entire process

#### Phase 6: Final Report
- Shows total number of items processed
- Reports any errors encountered
- Displays final permissions on the main folder

### Example Scenarios

#### Scenario 1: Standard Execution
```
Current permissions:
  BUILTIN\Administrators : FullControl (Allow)
  NT AUTHORITY\SYSTEM : FullControl (Allow)
  CONTOSO\Domain Users : ReadAndExecute (Allow)
  CONTOSO\MicrosUsers : Modify (Allow)

Do you want to grant Full Control...? Y

Result: All four groups get Full Control on folder and all contents
```

#### Scenario 2: User Cancellation
```
Current permissions:
  BUILTIN\Administrators : FullControl (Allow)
  NT AUTHORITY\SYSTEM : FullControl (Allow)

Do you want to grant Full Control...? N

Operation cancelled.
```

#### Scenario 3: Large Directory Structure
```
Applying permissions recursively...
  Processed 100 items...
  Processed 200 items...
  Processed 500 items...
  Processed 1000 items...

Recursive permission update completed!
  Total items processed: 1247
  Items with errors: 3
```

### Command Line Parameters

The script currently doesn't accept command line parameters. The folder path is hardcoded to `C:\Micros`.

### Customization Options

To modify the script for different folders, edit line 4:
```powershell
# Change this line to target a different folder
$folderPath = "C:\Micros"
```

### Performance Considerations

#### For Large Directory Structures:
- **Expected Speed**: ~50-100 items per second (varies by system)
- **Memory Usage**: Minimal - processes items one at a time
- **Disk I/O**: Moderate - reads/writes ACL for each item
- **Network Impact**: None for local folders, moderate for network shares

#### Optimization Tips:
- Run during off-peak hours for large directories
- Ensure adequate disk space for log files
- Close unnecessary applications to free up system resources

### Security Considerations

#### What the Script Does:
- ✅ Only modifies permissions on existing users/groups
- ✅ Preserves inherited permissions
- ✅ Requires explicit user confirmation
- ✅ Provides detailed logging of all changes

#### What the Script Does NOT Do:
- ❌ Add new users or groups
- ❌ Remove users or groups
- ❌ Modify ownership
- ❌ Change inherited permissions
- ❌ Work without Administrator privileges

### Verification Steps

After script completion, verify results:

```powershell
# Check main folder permissions
Get-Acl "C:\Micros" | Format-List

# Check a subfolder's permissions
Get-Acl "C:\Micros\SomeSubfolder" | Format-List

# Check a file's permissions
Get-Acl "C:\Micros\SomeSubfolder\SomeFile.txt" | Format-List
```

### Rollback Considerations

This script does not create automatic backups. Before running:

1. **Document Current State**:
   ```powershell
   Get-Acl "C:\Micros" | Export-Csv "C:\Backup\MicrosPermissions.csv"
   ```

2. **Create System Restore Point** (if applicable)

3. **Test on Smaller Directory First** (if possible)

### Integration with Other Tools

#### Group Policy:
- Script changes won't conflict with Group Policy inheritance
- Group Policy can override explicit permissions set by this script

#### Backup Software:
- Most backup software preserves permissions
- Restore operations will maintain the Full Control settings

#### Security Auditing:
- Changes will appear in Windows Security Event Log
- Use Event ID 4670 to track permission modifications