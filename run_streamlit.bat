@echo off
REM DiaRisk AI - Streamlit Quick Start

echo.
echo ========================================
echo DiaRisk AI - Streamlit Quick Start
echo ========================================
echo.

echo Step 1: Installing Streamlit dependencies...
pip install -r streamlit_requirements.txt -q

echo Step 2: Starting all services...
echo.
echo Make sure you have 3 terminals open:
echo.
echo Terminal 1 - Python ML Service:
echo   python diabetes_prediction.py
echo.
echo Terminal 2 - Node.js Backend:
echo   npm run dev
echo.
echo Terminal 3 - Streamlit App:
echo   streamlit run streamlit_app.py
echo.
echo.
echo Then visit: http://localhost:8501
echo.
echo To deploy to Streamlit Cloud:
echo   1. Push to GitHub
echo   2. Go to https://share.streamlit.io
echo   3. Click "New app" and select your repo
echo.
pause
