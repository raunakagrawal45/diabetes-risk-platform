#!/bin/bash
#
# Diabetes Prediction Platform - Automated Startup Script (Unix/macOS)
# This script handles the complete setup and startup process
#

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_header() { echo -e "\n${CYAN}============================================================${NC}"; echo -e "${CYAN}$1${NC}"; echo -e "${CYAN}============================================================${NC}\n"; }

# Detect Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PIP_CMD="pip3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PIP_CMD="pip"
else
    print_error "Python is not installed. Please install Python 3.8+"
    exit 1
fi

print_header "Diabetes Risk Prediction Platform - Startup"

# Step 1: Check Prerequisites
print_info "Checking prerequisites..."

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"
else
    print_error "Node.js is not installed. Please install from https://nodejs.org/"
    exit 1
fi

# Check Python
PYTHON_VERSION=$($PYTHON_CMD --version)
print_success "Python found: $PYTHON_VERSION"

# Step 2: Install Dependencies
print_info "Checking dependencies..."

if [ ! -d "node_modules" ]; then
    print_warning "Node.js dependencies not found. Installing..."
    npm install
    print_success "Node.js dependencies installed"
else
    print_success "Node.js dependencies already installed"
fi

# Check Python dependencies
print_info "Checking Python dependencies..."
if ! $PYTHON_CMD -c "import flask, sklearn, pandas, numpy, joblib" 2>/dev/null; then
    print_warning "Python dependencies not found. Installing..."
    $PIP_CMD install -r requirements.txt
    print_success "Python dependencies installed"
else
    print_success "Python dependencies already installed"
fi

# Step 3: Check Model Files
print_info "Checking for trained ML model..."

if [ ! -f "model.pkl" ] || [ ! -f "scaler.pkl" ]; then
    print_warning "ML model not found. Training model now..."
    print_info "This will take about 30-60 seconds..."
    
    $PYTHON_CMD diabetes_prediction.py
    
    if [ -f "model.pkl" ] && [ -f "scaler.pkl" ]; then
        MODEL_SIZE=$(du -h model.pkl | cut -f1)
        print_success "Model trained successfully (Size: $MODEL_SIZE)"
    else
        print_error "Model files were not created"
        exit 1
    fi
else
    MODEL_SIZE=$(du -h model.pkl | cut -f1)
    print_success "ML model already trained (Size: $MODEL_SIZE)"
    print_info "Skipping training. Delete model.pkl to retrain."
fi

# Step 4: Start Services
print_header "Starting Services"

# Cleanup function
cleanup() {
    print_info "Shutting down services..."
    if [ ! -z "$PYTHON_PID" ]; then
        kill $PYTHON_PID 2>/dev/null || true
    fi
    if [ ! -z "$NODE_PID" ]; then
        kill $NODE_PID 2>/dev/null || true
    fi
    print_success "Services stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start Python ML Service
print_info "Starting Python ML Service (Port 5000)..."
$PYTHON_CMD predict_service.py > python_service.log 2>&1 &
PYTHON_PID=$!

# Wait for Python service
print_info "Waiting for Python service to initialize..."
for i in {1..20}; do
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        print_success "Python ML Service is running (http://localhost:5000)"
        break
    fi
    sleep 1
done

# Start Node.js Frontend
print_info "Starting Frontend Server (Port 3000)..."
npm run dev > frontend.log 2>&1 &
NODE_PID=$!

# Wait for frontend
print_info "Waiting for frontend to initialize..."
for i in {1..20}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        print_success "Frontend Server is running (http://localhost:3000)"
        break
    fi
    sleep 1
done

# Final Status
print_header "Application Ready!"

echo ""
echo -e "  🚀 Frontend:        ${GREEN}http://localhost:3000${NC}"
echo -e "  🤖 Python ML API:   ${GREEN}http://localhost:5000${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Open browser (macOS/Linux)
if command -v open &> /dev/null; then
    open http://localhost:3000
elif command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:3000
fi

# Keep services running
print_info "Services are running. Logs: python_service.log, frontend.log"
wait
