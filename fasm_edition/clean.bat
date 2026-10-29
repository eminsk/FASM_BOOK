@echo off
setlocal
echo [*] Cleaning up build artifacts in fasm_edition...
cd /d "%~dp0"
del /s /q *.exe *.dll *.obj *.bin 2>nul
echo [+] Clean complete.
