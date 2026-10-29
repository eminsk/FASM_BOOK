@echo off
setlocal enabledelayedexpansion
title FASM Edition - Master Project Builder
color 0A

echo ===============================================================================
echo               FASM Edition: Building Full x64 Assembly Suite
echo ===============================================================================
echo.

set "FASM_BIN=%~dp0..\tools\fasm\FASM.EXE"
set "INCLUDE=%~dp0..\tools\fasm\INCLUDE"

if not exist "%FASM_BIN%" (
    color 0C
    echo [ERROR] FASM.EXE not found at "%FASM_BIN%"!
    pause
    exit /b 1
)

set /a SUCCESS_COUNT=0
set /a FAIL_COUNT=0

for /r "%~dp0" %%f in (*.asm) do (
    set "SRC=%%f"
    set "DIR=%%~dpf"
    set "NAME=%%~nf"
    set "OUT_EXT=exe"
    if "!NAME!"=="fast_math" set "OUT_EXT=dll"
    
    echo [*] Assembling !NAME!.asm ...
    "%FASM_BIN%" "!SRC!" "!DIR!!NAME!.!OUT_EXT!" > nul 2>&1
    if not errorlevel 1 (
        echo     [+] SUCCESS: !NAME!.!OUT_EXT!
        set /a SUCCESS_COUNT+=1
    ) else (
        color 0C
        echo     [-] FAILED:  !NAME!.asm
        "%FASM_BIN%" "!SRC!" "!DIR!!NAME!.!OUT_EXT!"
        set /a FAIL_COUNT+=1
    )
)

echo.
echo ===============================================================================
echo Build Complete!
echo Successful: %SUCCESS_COUNT%
echo Failed:     %FAIL_COUNT%
echo ===============================================================================
echo.

if %FAIL_COUNT% GTR 0 (
    color 0C
    echo Some targets failed to compile.
    exit /b 1
) else (
    color 0A
    echo All targets compiled with 100%% perfection!
    exit /b 0
)
