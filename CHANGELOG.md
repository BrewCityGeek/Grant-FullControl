# Changelog

All notable changes to the Grant-FullControl script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-30

### Added
- **Recursive Permission Application**: Script now applies permissions to ALL subfolders and files within C:\Micros
- **Progress Tracking**: Shows progress every 100 items processed during recursive operation
- **Enhanced Error Handling**: Individual item failures don't stop the entire process
- **Detailed Reporting**: Shows total items processed and error count
- **Item-by-Item Processing**: Each subfolder and file gets explicit permission updates
- **Comprehensive Status Updates**: Better user feedback throughout the process

### Changed
- **User Confirmation Message**: Updated to clearly indicate recursive operation
- **Script Description**: Updated headers and comments to reflect recursive functionality
- **Output Messages**: Enhanced messages to distinguish between main folder and recursive processing phases
- **Error Isolation**: Errors on individual items are reported but don't halt execution

### Enhanced
- **Performance**: Optimized for large directory structures
- **Safety**: Maintains inherited permissions while updating explicit ones
- **Logging**: Better error reporting with specific file paths
- **User Experience**: Clearer progress indication and status messages

## [1.0.0] - Previous Version

### Features
- **Basic Permission Granting**: Granted Full Control to existing users/groups on main folder only
- **Permission Preview**: Displayed current permissions before making changes
- **User Confirmation**: Required explicit confirmation before proceeding
- **Safety Checks**: Validated folder existence and administrator privileges
- **Inheritance Support**: Used ContainerInherit and ObjectInherit flags

### Limitations
- Only applied permissions to the main C:\Micros folder
- Relied solely on inheritance for subfolder and file permissions
- No explicit processing of existing subfolders and files
- Limited progress feedback for large operations

## Migration Notes

### From v1.0 to v2.0

#### What's Different:
- **Execution Time**: v2.0 takes significantly longer due to recursive processing
- **Output Volume**: More detailed progress and status messages
- **Error Handling**: More granular error reporting per item
- **Resource Usage**: Higher CPU and disk I/O during recursive phase

#### Compatibility:
- **Same Prerequisites**: Still requires Administrator rights
- **Same Target**: Still targets C:\Micros folder
- **Same Input**: No changes to user interaction requirements
- **Same Safety**: Maintains all existing safety features

#### Recommended Actions:
1. **Test First**: Run on a smaller test directory if possible
2. **Plan Timing**: Allow extra time for large directory structures
3. **Monitor Resources**: Watch system performance during execution
4. **Review Logs**: Check error messages for any problematic files

## Future Considerations

### Potential Enhancements:
- **Configurable Path**: Allow command-line parameter for folder path
- **Backup Creation**: Automatic permission backup before changes
- **Selective Processing**: Options to skip certain file types or paths
- **Parallel Processing**: Multi-threaded operation for better performance
- **Resume Capability**: Ability to resume interrupted operations
- **Custom Log Files**: Detailed logging to file with timestamps

### Known Limitations:
- **Single Folder Target**: Currently hardcoded to C:\Micros
- **No Rollback**: No automatic undo functionality
- **Sequential Processing**: Processes items one at a time
- **Memory Usage**: Loads full directory list into memory

## Version History Summary

| Version | Release Date | Key Features |
|---------|--------------|--------------|
| 2.0.0   | 2025-10-30   | Recursive processing, progress tracking, enhanced error handling |
| 1.0.0   | Previous     | Basic permission granting, safety checks, user confirmation |