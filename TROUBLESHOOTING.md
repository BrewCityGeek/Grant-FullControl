# Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "Access Denied" Error

#### Symptoms:
```
Set-Acl : Access is denied
At line 67 char 13
+ Set-Acl -Path $folderPath -AclObject $newAcl
```

#### Causes:
- Script not running as Administrator
- User account lacks permission to modify ACLs
- Folder is in use by another process

#### Solutions:
1. **Ensure Administrator Rights**:
   ```powershell
   # Check if running as admin
   ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
   ```

2. **Close Applications**: Close any applications that might be using files in the C:\Micros folder

3. **Check File Locks**:
   ```powershell
   # Use Handle.exe or Process Explorer to find file locks
   ```

### Issue 2: "Folder Does Not Exist" Error

#### Symptoms:
```
Folder 'C:\Micros' does not exist!
```

#### Solutions:
1. **Verify Path**: Ensure the folder path is correct
2. **Create Folder**: Create the folder if it should exist
3. **Check Spelling**: Verify folder name spelling
4. **Network Drives**: Ensure network drives are connected (if applicable)

### Issue 3: Script Hangs or Runs Very Slowly

#### Symptoms:
- Script appears to freeze
- Very slow progress through items
- High disk or CPU usage

#### Causes:
- Very large directory structure
- Network latency (for network shares)
- Antivirus scanning interference
- Insufficient system resources

#### Solutions:
1. **Monitor Progress**: Script shows progress every 100 items
2. **Temporary Antivirus Exclusion**: Add C:\Micros to antivirus exclusions temporarily
3. **Run During Off-Peak Hours**: Execute when system load is lower
4. **Check Available Resources**:
   ```powershell
   Get-Process PowerShell | Select-Object CPU, WorkingSet
   ```

### Issue 4: "Failed to Set Permissions" Warnings

#### Symptoms:
```
WARNING: Failed to set permissions for 'C:\Micros\somefile.txt': Access is denied
```

#### Causes:
- Individual files are locked or in use
- Files have special attributes (system, hidden)
- Corrupted file system entries

#### Solutions:
1. **Review Locked Files**: Check which specific files failed
2. **Retry Later**: Some files may be temporarily locked
3. **Manual Investigation**:
   ```powershell
   # Check specific file attributes
   Get-ItemProperty "C:\Micros\problematic-file.txt" | Select-Object Attributes
   ```

### Issue 5: PowerShell Execution Policy Restrictions

#### Symptoms:
```
.\Grant-FullControl.ps1 : File cannot be loaded because running scripts is disabled on this system
```

#### Solutions:
1. **Check Current Policy**:
   ```powershell
   Get-ExecutionPolicy
   ```

2. **Temporary Policy Change**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```

3. **Unblock Script File**:
   ```powershell
   Unblock-File ".\Grant-FullControl.ps1"
   ```

### Issue 6: Unexpected Permission Results

#### Symptoms:
- Permissions don't appear as expected after script completion
- Some users/groups missing from final permissions

#### Investigation Steps:
1. **Check Inheritance**:
   ```powershell
   (Get-Acl "C:\Micros").Access | Where-Object {$_.IsInherited -eq $false}
   ```

2. **Verify Group Membership**:
   ```powershell
   whoami /groups
   ```

3. **Review Event Logs**:
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4670} -MaxEvents 50
   ```

### Issue 7: High Error Count in Results

#### Symptoms:
```
Items with errors: 127
```

#### Investigation Steps:
1. **Check File System Health**:
   ```powershell
   chkdsk C: /f /r
   ```

2. **Review File Attributes**:
   ```powershell
   Get-ChildItem "C:\Micros" -Recurse | Where-Object {$_.Attributes -match "System|Hidden"}
   ```

3. **Test Specific Paths**:
   ```powershell
   # Test permission setting on a specific file
   $testPath = "C:\Micros\specific-file.txt"
   try {
       $acl = Get-Acl $testPath
       Set-Acl $testPath $acl
       Write-Host "Success"
   } catch {
       Write-Host "Error: $($_.Exception.Message)"
   }
   ```

### Issue 8: Script Stops with "Out of Memory" Error

#### Symptoms:
- PowerShell process crashes
- System becomes unresponsive
- Out of memory errors

#### Solutions:
1. **Increase Virtual Memory**: Adjust system page file size
2. **Process in Batches**: Modify script to process smaller chunks
3. **Use 64-bit PowerShell**: Ensure using 64-bit version for large datasets

### Issue 9: Network Share Timeouts

#### Symptoms:
- Script fails when C:\Micros is on a network share
- Intermittent connection errors

#### Solutions:
1. **Map Drive Permanently**:
   ```powershell
   net use C: \\server\share /persistent:yes
   ```

2. **Increase Timeout Values**: Modify network adapter settings
3. **Use UNC Path**: Modify script to use UNC path instead of mapped drive

### Diagnostic Commands

#### System Information:
```powershell
# PowerShell version
$PSVersionTable

# Current user and privileges
whoami /all

# Available memory
Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

# Disk space
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace
```

#### Permission Analysis:
```powershell
# Detailed ACL analysis
$acl = Get-Acl "C:\Micros"
$acl.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType, IsInherited -AutoSize

# Find files with explicit permissions
Get-ChildItem "C:\Micros" -Recurse | ForEach-Object {
    $fileAcl = Get-Acl $_.FullName
    if ($fileAcl.Access | Where-Object {$_.IsInherited -eq $false}) {
        Write-Host $_.FullName
    }
}
```

### Getting Additional Help

If issues persist:

1. **Check Windows Event Logs**: Look for related error messages
2. **Test with Small Directory**: Try script on a smaller test folder first
3. **Review Security Policies**: Ensure no Group Policy restrictions
4. **Contact System Administrator**: For domain-joined computers

### Log File Analysis

The script doesn't create log files by default, but you can redirect output:

```powershell
.\Grant-FullControl.ps1 2>&1 | Tee-Object -FilePath "C:\Logs\PermissionScript.log"
```

This creates a log file with all output and error messages for later analysis.