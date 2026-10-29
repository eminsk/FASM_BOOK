@echo off
setlocal
cd /d "%~dp0fasm_edition"
powershell -ExecutionPolicy Bypass -File test_all.ps1
