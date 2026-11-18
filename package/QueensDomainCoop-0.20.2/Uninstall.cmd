@echo off
rem Double-click to uninstall the co-op mod (runs uninstall.ps1 with PowerShell).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" %*
pause
