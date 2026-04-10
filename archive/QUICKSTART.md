# 🚀 Quick Start Guide

## Run the App (One Command)

### Windows
```bash
start.bat
```

### macOS/Linux  
```bash
./start.sh
```

### All Platforms (npm)
```bash
npm start
```

## What Happens Automatically

✅ Checks prerequisites (Node.js, Python)  
✅ Installs dependencies if needed  
✅ **Trains ML model ONLY if model.pkl doesn't exist**  
✅ Starts Python ML service (Port 5000)  
✅ Starts frontend server (Port 3000)  
✅ Opens browser to http://localhost:3000  

## First Run vs Subsequent Runs

| Operation | First Run | After First Run |
|-----------|-----------|-----------------|
| Check prerequisites | ✓ | ✓ |
| Install dependencies | If needed | Skip if exists |
| **Train ML model** | **✓ (~60s)** | **SKIP (cached)** |
| Start services | ✓ | ✓ |
| **Total time** | **~90s** | **~10s** |

## Force Retrain Model

Delete the model files:
```bash
# Windows
del model.pkl scaler.pkl

# macOS/Linux
rm model.pkl scaler.pkl
```

Then run the startup script again.

## Stop Services

Press `Ctrl+C` in the terminal window.

## Manual Control (Advanced)

If you prefer to run services separately:

```bash
# Terminal 1: Python ML Service
python predict_service.py

# Terminal 2: Frontend
npm run dev
```

## Troubleshooting

**Port already in use?**
```bash
# Windows
netstat -ano | findstr :3000
netstat -ano | findstr :5000

# Stop process
taskkill /PID <pid> /F
```

**Model not training?**
- Check `diabetes.csv` exists
- Verify Python packages: `pip install -r requirements.txt`

**Frontend not starting?**
- Verify Node packages: `npm install`
- Clear cache: `npm clean-cache --force`

---

## 📖 Full Documentation

- [PIPELINE.md](PIPELINE.md) - Complete pipeline documentation
- [README.md](README.md) - Full setup guide
- [SETUP.md](SETUP.md) - Manual setup instructions
- [INTEGRATION.md](INTEGRATION.md) - How components connect

---

**That's it! You never need to manually train the model again.** 🎉

The pipeline checks if the model exists and only trains when necessary.
