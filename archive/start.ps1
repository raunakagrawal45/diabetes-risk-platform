#!/usr/bin/env pwsh
#
# Diabetes Prediction Platform - Automated Startup Script
# This script handles the complete setup and startup process
#

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Header { param($msg) Write-Host "`n$('='*60)" -ForegroundColor Cyan; Write-Host $msg -ForegroundColor Cyan; Write-Host "$('='*60)`n" -ForegroundColor Cyan }

Write-Header "Diabetes Risk Prediction Platform - Startup"

# Step 1: Check Prerequisites
Write-Info "Checking prerequisites..."

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Success "Node.js found: $nodeVersion"
} catch {
    Write-Error "Node.js is not installed. Please install from https://nodejs.org/"
    exit 1
}

# Check Python
try {
    $pythonVersion = python --version
    Write-Success "Python found: $pythonVersion"
} catch {
    Write-Error "Python is not installed. Please install from https://www.python.org/"
    exit 1
}

# Step 2: Install Dependencies (if needed)
Write-Info "Checking dependencies..."

if (-not (Test-Path "node_modules")) {
    Write-Warning "Node.js dependencies not found. Installing..."
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Node.js dependencies"
        exit 1
    }
    Write-Success "Node.js dependencies installed"
} else {
    Write-Success "Node.js dependencies already installed"
}

# Check Python dependencies
Write-Info "Checking Python dependencies..."
$pipCheck = python -c "import flask, sklearn, pandas, numpy, joblib" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Python dependencies not found. Installing..."
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Python dependencies"
        exit 1
    }
    Write-Success "Python dependencies installed"
} else {
    Write-Success "Python dependencies already installed"
}

# Step 3: Check Model Files
Write-Info "Checking for trained ML model..."

$modelExists = Test-Path "model.pkl"
$scalerExists = Test-Path "scaler.pkl"

if (-not $modelExists -or -not $scalerExists) {
    Write-Warning "ML model not found. Training model now..."
    Write-Info "This will take about 30-60 seconds..."
    
    python diabetes_prediction.py
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Model training failed"
        exit 1
    }
    
    if ((Test-Path "model.pkl") -and (Test-Path "scaler.pkl")) {
        $modelSize = (Get-Item "model.pkl").Length / 1MB
        Write-Success "Model trained successfully (Size: $($modelSize.ToString('0.00')) MB)"
    } else {
        Write-Error "Model files were not created"
        exit 1
    }
} else {
    $modelSize = (Get-Item "model.pkl").Length / 1MB
    Write-Success "ML model already trained (Size: $($modelSize.ToString('0.00')) MB)"
    Write-Info "Skipping training. Delete model.pkl to retrain."
}

# Step 4: Start Services
Write-Header "Starting Services"

# Kill any existing processes on these ports
Write-Info "Checking for processes on ports 3000 and 5000..."
Get-Process -Name "node", "python" -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -eq "node" -or $_.ProcessName -eq "python"
} | ForEach-Object {
    try {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    } catch {}
}
Start-Sleep -Seconds 1

# Start Python ML Service
Write-Info "Starting Python ML Service (Port 5000)..."
$pythonJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    python predict_service.py
}

# Wait for Python service to be ready
Write-Info "Waiting for Python service to initialize..."
$maxAttempts = 20
$attempt = 0
$pythonReady = $false

while ($attempt -lt $maxAttempts -and -not $pythonReady) {
    Start-Sleep -Seconds 1
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $pythonReady = $true
            Write-Success "Python ML Service is running (http://localhost:5000)"
        }
    } catch {
        $attempt++
    }
}

if (-not $pythonReady) {
    Write-Error "Python service failed to start"
    Stop-Job $pythonJob -ErrorAction SilentlyContinue
    Remove-Job $pythonJob -ErrorAction SilentlyContinue
    exit 1
}

# Start Node.js Frontend
Write-Info "Starting Frontend Server (Port 3000)..."
$nodeJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    npm run dev
}

# Wait for Node service to be ready
Write-Info "Waiting for frontend to initialize..."
$attempt = 0
$nodeReady = $false

while ($attempt -lt $maxAttempts -and -not $nodeReady) {
    Start-Sleep -Seconds 1
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $nodeReady = $true
            Write-Success "Frontend Server is running (http://localhost:3000)"
        }
    } catch {
        $attempt++
    }
}

if (-not $nodeReady) {
    Write-Warning "Frontend may still be starting..."
}

# Final Status
Write-Header "Application Ready!"

Write-Host ""
Write-Host "  🚀 Frontend:        " -NoNewline -ForegroundColor White
Write-Host "http://localhost:3000" -ForegroundColor Green
Write-Host "  🤖 Python ML API:   " -NoNewline -ForegroundColor White
Write-Host "http://localhost:5000" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop all services and exit" -ForegroundColor Yellow
Write-Host ""

# Open browser
Write-Info "Opening browser..."
Start-Process "http://localhost:3000"

# Keep services running
Write-Info "Monitoring services (Press Ctrl+C to stop)..."
try {
    while ($true) {
        Start-Sleep -Seconds 5
        
        # Check if jobs are still running
        $pythonState = (Get-Job -Id $pythonJob.Id -ErrorAction SilentlyContinue).State
        $nodeState = (Get-Job -Id $nodeJob.Id -ErrorAction SilentlyContinue).State
        
        if ($pythonState -eq "Failed" -or $nodeState -eq "Failed") {
            Write-Error "One or more services have failed"
            break
        }
    }
} catch {
    Write-Info "Shutting down..."
} finally {
    # Cleanup on exit
    Write-Info "Stopping services..."
    Stop-Job $pythonJob -ErrorAction SilentlyContinue
    Stop-Job $nodeJob -ErrorAction SilentlyContinue
    Remove-Job $pythonJob -ErrorAction SilentlyContinue
    Remove-Job $nodeJob -ErrorAction SilentlyContinue
    
    # Kill any remaining processes
    Get-Process -Name "node", "python" -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*$PWD*"
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-Success "Services stopped"
}
