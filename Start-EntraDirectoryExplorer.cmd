@echo off
setlocal

where pwsh.exe >nul 2>&1
if errorlevel 1 goto WindowsPowerShell

pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0EntraDirectoryExplorer.ps1"
goto Finished

:WindowsPowerShell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0EntraDirectoryExplorer.ps1"

:Finished
if errorlevel 1 pause
