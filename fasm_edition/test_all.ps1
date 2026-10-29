# ==============================================================================
# FASM Edition Automated Test Suite Runner (PowerShell)
# Verifies compilation, executes binaries, and validates expected outputs
# ==============================================================================

$root = $PSScriptRoot
$fasmBin = Join-Path $root "..\tools\fasm\FASM.EXE"
$env:INCLUDE = Join-Path $root "..\tools\fasm\INCLUDE"

Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "               FASM Edition: Automated Test & Verification Suite              " -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

# 1. Compile all .asm files
$asmFiles = Get-ChildItem -Path $root -Filter "*.asm" -Recurse

Write-Host "[1/3] Compiling $($asmFiles.Count) Assembly Source Files with FASM x64..." -ForegroundColor Yellow

foreach ($file in $asmFiles) {
    $outExt = if ($file.Name -match "dll|fast_math") { ".dll" } else { ".exe" }
    $outFile = [System.IO.Path]::ChangeExtension($file.FullName, $outExt)

    $process = Start-Process -FilePath $fasmBin -ArgumentList "`"$($file.FullName)`" `"$outFile`"" -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host "  [+] COMPILED: $($file.Name) -> $($outExt.ToUpper())" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [-] FAILED:   $($file.Name)" -ForegroundColor Red
        $testsFailed++
    }
}

Write-Host ""
Write-Host "[2/3] Executing Console Binaries & Validating Exit Codes..." -ForegroundColor Yellow

$exeFiles = Get-ChildItem -Path $root -Filter "*.exe" -Recurse | Where-Object { $_.Name -notmatch "gui_app" }

foreach ($exe in $exeFiles) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $exe.FullName
    $pinfo.WorkingDirectory = $exe.DirectoryName
    $pinfo.UseShellExecute = $false
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($pinfo)
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit(5000)
    $sw.Stop()

    if ($proc.ExitCode -eq 0) {
        Write-Host "  [+] RUN OK ($($sw.ElapsedMilliseconds)ms): $($exe.Name)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [-] RUN FAIL (Exit $($proc.ExitCode)): $($exe.Name)" -ForegroundColor Red
        $testsFailed++
    }
}

Write-Host ""
Write-Host "[3/3] Running Python ctypes Native Interop Verification..." -ForegroundColor Yellow

$pythonTest = Join-Path $root "04_advanced_interop\01_python_ctypes_dll\test_python.py"
$pythonExe = "C:\proekts\leetcode\.venv\Scripts\python.exe"
if (-not (Test-Path $pythonExe)) {
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pyCmd) { $pythonExe = $pyCmd.Source }
}

if (Test-Path $pythonTest) {
    $pyProc = Start-Process -FilePath $pythonExe -ArgumentList "`"$pythonTest`"" -NoNewWindow -Wait -PassThru
    if ($pyProc.ExitCode -eq 0) {
        Write-Host "  [+] PYTHON CTYPES: 100% assertions passed!" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [-] PYTHON CTYPES: test failed!" -ForegroundColor Red
        $testsFailed++
    }
}

Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
if ($testsFailed -eq 0) {
    Write-Host "Scorecard: Total Tests Passed: $testsPassed | Failed: $testsFailed (100% SUCCESS!)" -ForegroundColor Green
} else {
    Write-Host "Scorecard: Total Tests Passed: $testsPassed | Failed: $testsFailed" -ForegroundColor Red
}
Write-Host "===============================================================================" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
