#!/bin/bash

# Diabetes Risk Prediction Platform - Setup Script

echo ""
echo "==================================================="
echo "  Diabetes Risk Prediction Platform"
echo "==================================================="
echo ""

# Check if Node.js is installed
echo "Checking for Node.js..."
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi
echo "✓ Node.js found: $(node --version)"

# Check if Python is installed
echo "Checking for Python..."
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "Error: Python is not installed"
        echo "Please install Python 3.8+ from https://www.python.org/"
        exit 1
    fi
    PYTHON_CMD="python"
else
    PYTHON_CMD="python3"
fi
echo "✓ Python found: $($PYTHON_CMD --version)"

echo ""
echo "Step 1: Installing Node.js dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "Error: npm install failed"
    exit 1
fi
echo "✓ Node dependencies installed"

echo ""
echo "Step 2: Installing Python dependencies..."
$PYTHON_CMD -m pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Error: pip install failed"
    exit 1
fi
echo "✓ Python dependencies installed"

# Check if model files exist
if [ ! -f "model.pkl" ]; then
    echo ""
    echo "Step 3: Training ML Model..."
    $PYTHON_CMD diabetes_prediction.py
    if [ $? -ne 0 ]; then
        echo "Error: Model training failed"
        exit 1
    fi
    echo "✓ Model trained and saved"
else
    echo "✓ Model already trained (model.pkl exists)"
fi

echo ""
echo "==================================================="
echo "  Setup Complete! Ready to start the application"
echo "==================================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Open Terminal 1 and run:"
echo "   python3 predict_service.py"
echo ""
echo "2. Open Terminal 2 and run:"
echo "   npm run dev"
echo ""
echo "3. Open browser to:"
echo "   http://localhost:3000"
echo ""
echo "For more details, see SETUP.md or README.md"
echo ""
