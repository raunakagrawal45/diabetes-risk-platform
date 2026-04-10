@echo off
REM Diabetes Prediction Platform - Windows Batch Startup Script
REM This batch file launches the PowerShell startup script

echo.
echo ============================================================
echo  Diabetes Risk Prediction Platform
echo ============================================================
echo.
echo Starting application...
echo.

REM Check if PowerShell is available
where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    pwsh -ExecutionPolicy Bypass -File "%~dp0start.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1"
)

pause
