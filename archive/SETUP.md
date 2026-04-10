# Quick Start Guide - Diabetes Risk Prediction Platform

This guide walks you through setting up and running the complete application.

## ⚡ Quick Setup (5 minutes)

### Step 1: Install Node.js Dependencies
```bash
npm install
```

### Step 2: Install Python Dependencies
```bash
pip install -r requirements.txt
```

### Step 3: Train ML Model (First time only)
```bash
python diabetes_prediction.py
```
This creates `model.pkl` and `scaler.pkl` that the backend will use.

## 🚀 Running the Application

You need **3 terminal windows** to run the complete stack:

### Terminal 1: Start Python ML Service
```bash
python predict_service.py
```
Expected output:
```
============================================================
Starting Diabetes Prediction Service
============================================================
Server running on http://localhost:5000
```
✅ Leave this running

### Terminal 2: Start Frontend
```bash
npm run dev
```
Expected output:
```
VITE v6.x.x  ready in XXX ms

➜  Local:   http://localhost:3000/
```
✅ Open browser to http://localhost:3000

### Terminal 3 (Optional): View Node Logs
Just shows the frontend being served on port 3000.

## 📊 Testing the Application

1. Open http://localhost:3000 in your browser
2. Go to **"Prediction"** page
3. Enter patient clinical data:
   - Example: Diabetes positive case
     - Pregnancies: 6
     - Glucose: 148
     - Blood Pressure: 72
     - Skin Thickness: 35
     - Insulin: 0
     - BMI: 33.6
     - Diabetes Pedigree Function: 0.627
     - Age: 50
4. Click **"Analyze Risk"**
5. See the prediction result: "Diabetic", "High" risk, probability, etc.

## 🔥 How It Works

```
Browser (React)
    ↓
Node.js Server (Express) - Port 3000
    ↓
Python Flask Backend - Port 5000
    ↓
ML Model (Random Forest)
    ↓
Prediction Result
```

## ✨ Data Flow

1. **Frontend** collects 8 clinical parameters
2. **User clicks "Analyze Risk"** button
3. **Frontend sends data** to Node.js API (`/api/predict`)
4. **Node.js forwards request** to Python service (http://localhost:5000)
5. **Python Flask service**:
   - Scales input using the trained StandardScaler
   - Loads Random Forest model
   - Makes prediction
   - Returns probability and risk level
6. **Frontend displays** results with:
   - Prediction: "Diabetic" / "Non-Diabetic"
   - Risk Level: "Low" / "Medium" / "High" / "Very High"
   - Confidence: Percentage confidence score

## 📋 Model Information

**Model Type:** Random Forest Classifier
**Features:** 8 clinical parameters
**Dataset:** PIMA Indians Diabetes (768 samples)
**Accuracy:** ~77% on test set
**Classes:** Binary (Diabetic / Non-Diabetic)

## ❌ Troubleshooting

### Error: "Python service unavailable"
- Make sure `python predict_service.py` is running
- Check port 5000 is free: `netstat -ano | findstr :5000` (Windows)

### Error: "Model not found"
- Run `python diabetes_prediction.py` to train the model
- Check `model.pkl` and `scaler.pkl` exist in project root

### Port already in use
- Node.js server uses port 3000
- Python service uses port 5000
- If ports are in use, stop other services or modify ports in code

### Python dependencies missing
- Run: `pip install -r requirements.txt --upgrade`

## 📁 Key Files

- `diabetes_prediction.py` - Trains ML models and saves them
- `predict_service.py` - Flask backend that serves predictions
- `server.ts` - Node.js Express API gateway
- `src/pages/Prediction.tsx` - React form for user input
- `src/services/api.ts` - Frontend API client
- `model.pkl` - Trained Random Forest model (created after first run)
- `scaler.pkl` - Feature scaler (created after first run)

## 🎯 Next Steps

1. ✅ Install dependencies
2. ✅ Train the model
3. ✅ Start Python service
4. ✅ Start frontend
5. ✅ Test predictions
6. 🚀 Deploy to production (see README.md)

## 🆘 Need Help?

- Check logs in each terminal for error messages
- Ensure all services are running on correct ports
- Verify `diabetes.csv` is in the project root
- Confirm Python 3.8+ and Node.js 16+ are installed

---

**Enjoy accurate diabetes risk predictions! 🎉**
