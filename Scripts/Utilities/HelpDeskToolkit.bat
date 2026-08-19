@echo off

echo Current Folder:
echo %~dp0
echo.

set USBROOT=%~dp0..\..

echo USB Root:
echo %USBROOT%
echo.

pause

PowerShell -NoProfile -ExecutionPolicy Bypass -File "%USBROOT%\Scripts\Utilities\TechToolkit.ps1"

pause