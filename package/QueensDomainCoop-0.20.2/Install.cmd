@echo off
rem Double-click to install the co-op mod (runs install.ps1 with PowerShell).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause
