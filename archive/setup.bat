@echo off
REM Diabetes Risk Prediction Platform - Windows Quick Start

echo.
echo ===================================================
echo  Diabetes Risk Prediction Platform
echo ===================================================
echo.

REM Check if Node.js is installed
echo Checking for Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo ✓ Node.js found: & node --version

REM Check if Python is installed
echo Checking for Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)
echo ✓ Python found: & python --version

echo.
echo Step 1: Installing Node.js dependencies...
call npm install
if errorlevel 1 (
    echo Error: npm install failed
    pause
    exit /b 1
)
echo ✓ Node dependencies installed

echo.
echo Step 2: Installing Python dependencies...
call pip install -r requirements.txt
if errorlevel 1 (
    echo Error: pip install failed
    pause
    exit /b 1
)
echo ✓ Python dependencies installed

REM Check if model files exist
if not exist model.pkl (
    echo.
    echo Step 3: Training ML Model...
    call python diabetes_prediction.py
    if errorlevel 1 (
        echo Error: Model training failed
        pause
        exit /b 1
    )
    echo ✓ Model trained and saved
) else (
    echo ✓ Model already trained (model.pkl exists)
)

echo.
echo ===================================================
echo  Setup Complete! Ready to start the application
echo ===================================================
echo.
echo Next steps:
echo.
echo 1. Open Terminal 1 and run:
echo    python predict_service.py
echo.
echo 2. Open Terminal 2 and run:
echo    npm run dev
echo.
echo 3. Open browser to:
echo    http://localhost:3000
echo.
echo For more details, see SETUP.md or README.md
echo.
pause
