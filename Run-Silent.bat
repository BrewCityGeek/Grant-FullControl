@echo off
REM Batch file to run Grant-FullControl.ps1 silently for scheduled tasks
REM This will run with no console output and log results to a file

cd /d "%~dp0"
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "Grant-FullControl.ps1" -Silent -Force -LogFile "Grant-FullControl.log"