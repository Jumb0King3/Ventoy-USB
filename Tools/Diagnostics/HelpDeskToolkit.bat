@echo off

set USBROOT=%~dp0..\..

NET SESSION >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%USBROOT%\Scripts\Utilities\TechToolkit.ps1""'"
    exit
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USBROOT%\Scripts\Utilities\TechToolkit.ps1"
