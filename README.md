

# Diabetes Risk Prediction Platform

A full-stack AI application for diabetes risk prediction using machine learning. This platform combines a React frontend with a Python machine learning backend.

## Architecture

- **Frontend**: React + TypeScript + Vite (Port 3000)
- **Node.js Server**: Express API gateway (Port 3000)
- **Python ML Backend**: Flask prediction service (Port 5000)
- **ML Model**: Random Forest trained on PIMA Indians Diabetes dataset

## Prerequisites

- **Node.js** (v16+)
- **Python** (v3.8+)
- **pip** (Python package manager)

## 🚀 Quick Start (Automated - Recommended)

The easiest way to run the application is using the automated startup scripts:

### Windows:
```bash
# Option 1: Double-click start.bat file
# OR Option 2: Run in terminal
.\start.bat

# OR Option 3: Using npm
npm start
```

### macOS/Linux:
```bash
chmod +x start.sh
./start.sh
```

**What it does automatically:**
- ✅ Checks Node.js and Python installation
- ✅ Installs dependencies if missing
- ✅ Trains ML model only if needed (skips if already trained)
- ✅ Starts Python ML service (Port 5000)
- ✅ Starts Frontend server (Port 3000)
- ✅ Opens browser automatically
- ✅ Monitors services (Ctrl+C to stop everything)

**That's it! The app will open at http://localhost:3000**

---

## Manual Setup (Advanced)

If you prefer manual control over each step:

### 1. Install Node.js Dependencies

```bash
npm install
```

This installs all required Node.js packages including Express, React, and other dependencies.

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

This installs scikit-learn, Flask, pandas, numpy, and other ML libraries needed for the prediction service.

### 3. Train the Machine Learning Model

Run the Python script to train the ML model on the diabetes dataset:

```bash
python diabetes_prediction.py
```

This will:
- Load and analyze the `diabetes.csv` dataset
- Train three ML models (Logistic Regression, Random Forest, Gradient Boosting)
- Save the best model (Random Forest) as `model.pkl`
- Save the feature scaler as `scaler.pkl`
- Display evaluation metrics and feature importance

**Expected Output:**
- `model.pkl` - Trained Random Forest model
- `scaler.pkl` - StandardScaler for feature normalization

### 4. Start the Python Prediction Service

In a new terminal, run the Flask backend:

```bash
python predict_service.py
```

You should see:
```
============================================================
Starting Diabetes Prediction Service
============================================================
Server running on http://localhost:5000
Health check: http://localhost:5000/health
Model info: http://localhost:5000/model-info
Predictions: POST to http://localhost:5000/predict
============================================================
```

### 5. Start the Frontend Server

In another terminal, run the frontend development server:

```bash
npm run dev
```

The app will be available at: **http://localhost:3000**

## How It Works

1. **User Input**: Enter patient clinical data in the web form
2. **Frontend**: Sends data to the Node.js API gateway
3. **Node.js Server**: Forwards the request to the Python Flask backend
4. **Python ML Service**: 
   - Scales the input features using the trained scaler
   - Loads the pre-trained Random Forest model
   - Makes a prediction and calculates probability
   - Returns results
5. **Frontend**: Displays prediction, risk level, and confidence score

## API Endpoints

### Node.js Server (http://localhost:3000)
- `POST /api/predict` - Send patient data for prediction
- `GET /api/health` - Health check (shows Python backend status)

### Python Service (http://localhost:5000)
- `POST /predict` - Diabetes prediction endpoint
- `GET /health` - Service health check
- `GET /model-info` - Model information

## Expected Input Format

```json
{
  "Pregnancies": 6,
  "Glucose": 148,
  "BloodPressure": 72,
  "SkinThickness": 35,
  "Insulin": 0,
  "BMI": 33.6,
  "DiabetesPedigreeFunction": 0.627,
  "Age": 50
}
```

## Expected Output Format

```json
{
  "prediction": "Diabetic",
  "probability": 0.8562,
  "risk_level": "High",
  "confidence": 95.62
}
```

## Features

- ✅ Real ML predictions using trained Random Forest model
- ✅ Accurate diabetes risk assessment
- ✅ User-friendly React interface
- ✅ Real-time predictions
- ✅ Responsive design with Tailwind CSS
- ✅ Error handling and fallback mode
- ✅ Model evaluation metrics and visualization

## Dataset

Uses the PIMA Indians Diabetes Dataset with 8 clinical features:
- Pregnancies
- Glucose level
- Blood Pressure
- Skin Thickness
- Insulin level
- BMI (Body Mass Index)
- Diabetes Pedigree Function
- Age

## Troubleshooting

### Python service not connecting
- Ensure `python predict_service.py` is running in a separate terminal
- Check that port 5000 is not in use
- Verify Python dependencies are installed: `pip install -r requirements.txt`

### Model not found error
- Run `python diabetes_prediction.py` to train and save the model
- Verify `model.pkl` and `scaler.pkl` exist in the project root

### Frontend not working
- Ensure Node.js is installed and dependencies are installed: `npm install`
- Check that port 3000 is not in use

## Run Locally (Quick Start)

### Automated (Easiest):
```bash
# Windows
.\start.bat

# macOS/Linux
./start.sh

# OR using npm (all platforms)
npm start
```

### Manual (if you prefer step-by-step):
```bash
# Terminal 1: Train model (one-time setup, only if model.pkl doesn't exist)
python diabetes_prediction.py

# Terminal 2: Start Python service
python predict_service.py

# Terminal 3: Start frontend
npm run dev

# Open browser to http://localhost:3000
```

## Environment Variables

Optional: Create a `.env.local` file if needed for API keys or custom configuration.

## Build for Production

```bash
npm run build
npm run preview
```

## View your app in AI Studio

https://ai.studio/apps/7567ca2c-cb20-42a0-bdd9-1873d096d035
