<#
.SYNOPSIS
    Test script for Grant-FullControl.ps1

.DESCRIPTION
    This script performs basic validation tests on the Grant-FullControl.ps1 script.
    Note: Full functionality tests require Windows environment with actual folders and ACLs.

.NOTES
    This is a basic validation script. Full testing requires Windows with appropriate permissions.
#>

[CmdletBinding()]
param()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Grant-FullControl.ps1" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "Grant-FullControl.ps1"

# Test 1: Check if script exists
Write-Host "Test 1: Verify script file exists..." -ForegroundColor Yellow
if (Test-Path $scriptPath) {
    Write-Host "  [PASS] Script file found at: $scriptPath" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Script file not found!" -ForegroundColor Red
    exit 1
}

# Test 2: Check script syntax
Write-Host "`nTest 2: Validate PowerShell syntax..." -ForegroundColor Yellow
try {
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Path $scriptPath -Raw), [ref]$errors)
    
    if ($errors.Count -eq 0) {
        Write-Host "  [PASS] No syntax errors found" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Syntax errors found:" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        exit 1
    }
} catch {
    Write-Host "  [FAIL] Error during syntax check: $_" -ForegroundColor Red
    exit 1
}

# Test 3: Check if script can be loaded
Write-Host "`nTest 3: Verify script can be loaded..." -ForegroundColor Yellow
try {
    $null = Get-Command $scriptPath -ErrorAction Stop
    Write-Host "  [PASS] Script loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Failed to load script: $_" -ForegroundColor Red
    exit 1
}

# Test 4: Check help documentation
Write-Host "`nTest 4: Verify help documentation..." -ForegroundColor Yellow
try {
    $help = Get-Help $scriptPath -ErrorAction Stop
    
    if ($help.Synopsis -and $help.Description) {
        Write-Host "  [PASS] Help documentation available" -ForegroundColor Green
        Write-Host "    Synopsis: $($help.Synopsis)" -ForegroundColor Gray
    } else {
        Write-Host "  [WARN] Help documentation incomplete" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [WARN] Could not retrieve help: $_" -ForegroundColor Yellow
}

# Test 5: Check parameters
Write-Host "`nTest 5: Verify script parameters..." -ForegroundColor Yellow
try {
    $params = (Get-Command $scriptPath).Parameters
    
    if ($params.ContainsKey('Path')) {
        Write-Host "  [PASS] Path parameter exists" -ForegroundColor Green
        $pathParam = $params['Path']
        Write-Host "    Default value: $($pathParam.Attributes.DefaultValue)" -ForegroundColor Gray
    } else {
        Write-Host "  [FAIL] Path parameter not found!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  [FAIL] Error checking parameters: $_" -ForegroundColor Red
    exit 1
}

# Test 6: Check for required functions
Write-Host "`nTest 6: Verify internal functions..." -ForegroundColor Yellow
$scriptContent = Get-Content -Path $scriptPath -Raw

$requiredFunctions = @('Test-Administrator', 'Grant-FullControl')
$allFound = $true

foreach ($func in $requiredFunctions) {
    if ($scriptContent -match "function $func") {
        Write-Host "  [PASS] Function '$func' found" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Function '$func' not found!" -ForegroundColor Red
        $allFound = $false
    }
}

if (-not $allFound) {
    exit 1
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All validation tests passed!" -ForegroundColor Green
Write-Host "`nNote: Full functionality testing requires:" -ForegroundColor Yellow
Write-Host "  - Windows operating system" -ForegroundColor Gray
Write-Host "  - Administrator privileges" -ForegroundColor Gray
Write-Host "  - Actual folder with ACLs to modify" -ForegroundColor Gray
Write-Host "`n[COMPLETED] Validation successful!`n" -ForegroundColor Green

exit 0
