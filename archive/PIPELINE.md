# Automated Pipeline Documentation

## Overview

The automated startup pipeline (`start.ps1`, `start.bat`, `start.sh`) intelligently manages the entire application lifecycle, ensuring you never need to manually train the model or start services.

## Pipeline Flow

```
┌─────────────────────────────────────────────────────────┐
│  START: Run start.bat / start.sh / npm start           │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  Step 1: Prerequisites Check                            │
│  - Verify Node.js installed                             │
│  - Verify Python installed                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  Step 2: Dependency Installation                        │
│  - Check if node_modules exists                         │
│    → If missing: Run npm install                        │
│  - Check if Python packages installed                   │
│    → If missing: Run pip install -r requirements.txt    │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  Step 3: ML Model Check (SMART CACHING)                │
│  - Check if model.pkl exists                            │
│  - Check if scaler.pkl exists                           │
│    ┌──────────────────────────────────────┐            │
│    │ IF BOTH EXIST:                       │            │
│    │   ✓ Skip training (use cached)       │            │
│    │   ✓ Show model size                  │            │
│    │   ✓ Continue to Step 4               │            │
│    └──────────────────────────────────────┘            │
│    ┌──────────────────────────────────────┐            │
│    │ IF MISSING:                          │            │
│    │   → Run python diabetes_prediction.py│            │
│    │   → Train all 3 models (~30-60s)     │            │
│    │   → Save best model (model.pkl)      │            │
│    │   → Save scaler (scaler.pkl)         │            │
│    │   ✓ Continue to Step 4               │            │
│    └──────────────────────────────────────┘            │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  Step 4: Service Startup                                │
│  - Start Python ML Service (Port 5000)                  │
│    → Background process                                 │
│    → Wait for health check                              │
│  - Start Node.js Frontend (Port 3000)                   │
│    → Background process                                 │
│    → Wait for health check                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  Step 5: Ready!                                         │
│  - Open browser to http://localhost:3000                │
│  - Monitor services                                     │
│  - Wait for Ctrl+C to shutdown                          │
└─────────────────────────────────────────────────────────┘
```

## Key Features

### 1. **Smart Model Caching**
The pipeline checks if `model.pkl` and `scaler.pkl` exist:
- **If they exist**: Skip training entirely (saves ~30-60 seconds)
- **If missing**: Train automatically and save for next time

**To force retraining**: Simply delete `model.pkl` and run the script again.

### 2. **Dependency Management**
Automatically installs missing dependencies:
- Node.js packages (`npm install`)
- Python packages (`pip install -r requirements.txt`)

### 3. **Health Checks**
Waits for services to be fully ready:
- Python service: Polls `http://localhost:5000/health`
- Frontend: Polls `http://localhost:3000`

### 4. **Graceful Shutdown**
Press `Ctrl+C` to:
- Stop Python ML service
- Stop Node.js frontend
- Clean up background processes
- Exit cleanly

### 5. **Automatic Browser Launch**
Opens your default browser to `http://localhost:3000` once ready.

## Usage

### Windows

**Option 1: Double-click**
```
Double-click: start.bat
```

**Option 2: Command Line**
```bash
.\start.bat
```

**Option 3: PowerShell directly**
```powershell
pwsh -ExecutionPolicy Bypass -File start.ps1
```

**Option 4: NPM**
```bash
npm start
```

### macOS / Linux

**Option 1: Shell script**
```bash
chmod +x start.sh
./start.sh
```

**Option 2: NPM**
```bash
npm start
```

## File Structure

```
diabetes-risk-prediction-platform/
├── start.ps1           # PowerShell automated pipeline
├── start.bat           # Windows batch wrapper
├── start.sh            # Unix/macOS shell script
├── diabetes_prediction.py    # ML model training
├── predict_service.py        # Flask ML API
├── server.ts                 # Node.js frontend server
├── model.pkl                 # Trained model (auto-generated)
├── scaler.pkl                # Feature scaler (auto-generated)
└── requirements.txt          # Python dependencies
```

## Behavior Examples

### First Run (No Model)
```
✓ Node.js found: v18.x.x
✓ Python found: Python 3.11.x
✓ Node.js dependencies already installed
✓ Python dependencies already installed
⚠ ML model not found. Training model now...
ℹ This will take about 30-60 seconds...
... (training output) ...
✓ Model trained successfully (Size: 1.62 MB)
✓ Python ML Service is running (http://localhost:5000)
✓ Frontend Server is running (http://localhost:3000)

============================================================
Application Ready!
============================================================

  🚀 Frontend:        http://localhost:3000
  🤖 Python ML API:   http://localhost:5000

Press Ctrl+C to stop all services and exit
```

### Subsequent Runs (Model Exists)
```
✓ Node.js found: v18.x.x
✓ Python found: Python 3.11.x
✓ Node.js dependencies already installed
✓ Python dependencies already installed
✓ ML model already trained (Size: 1.62 MB)
ℹ Skipping training. Delete model.pkl to retrain.
✓ Python ML Service is running (http://localhost:5000)
✓ Frontend Server is running (http://localhost:3000)

============================================================
Application Ready!
============================================================

  🚀 Frontend:        http://localhost:3000
  🤖 Python ML API:   http://localhost:5000

Press Ctrl+C to stop all services and exit
```

## Troubleshooting

### Pipeline fails at prerequisites
**Problem**: Node.js or Python not found
**Solution**: Install Node.js from https://nodejs.org/ and Python from https://www.python.org/

### Pipeline fails at dependency installation
**Problem**: npm or pip fails
**Solution**: Check internet connection, try running manually:
```bash
npm install
pip install -r requirements.txt
```

### Model training fails
**Problem**: Python crashes during training
**Solution**: 
- Check `diabetes.csv` exists in project root
- Verify Python packages installed correctly
- Check available disk space (~2MB needed)

### Services fail to start
**Problem**: Ports 3000 or 5000 already in use
**Solution**: 
- Close other applications using these ports
- Find process: `netstat -ano | findstr :3000` (Windows)
- Kill process: `taskkill /PID <pid> /F`

### Browser doesn't open
**Problem**: Browser fails to launch automatically
**Solution**: Manually open http://localhost:3000

## Advanced Usage

### Force Model Retraining
```bash
# Delete model files
Remove-Item model.pkl, scaler.pkl

# Run pipeline (will retrain)
.\start.bat
```

### Run Services Separately
```bash
# Python only
python predict_service.py

# Frontend only (in new terminal)
npm run dev
```

### Check Service Status
```bash
# Python service
curl http://localhost:5000/health

# Frontend
curl http://localhost:3000/api/health
```

### View Logs (Unix/macOS)
```bash
# Python service logs
tail -f python_service.log

# Frontend logs
tail -f frontend.log
```

## Environment Variables

None required! The pipeline uses defaults:
- Python service: Port 5000
- Frontend: Port 3000

To customize, edit:
- `predict_service.py`: Change `PORT = 5000`
- `server.ts`: Change `PORT = 3000`

## CI/CD Integration

The pipeline can be used in CI/CD:

```yaml
# Example GitHub Actions
steps:
  - uses: actions/checkout@v2
  - uses: actions/setup-node@v2
  - uses: actions/setup-python@v2
  
  # Install & train (model will be cached)
  - run: npm install
  - run: pip install -r requirements.txt
  - run: python diabetes_prediction.py
  
  # Run tests
  - run: npm test
```

## Performance

| Operation | Time | Cached |
|-----------|------|--------|
| Prerequisites check | <1s | Always |
| Dependency install (first) | 30-60s | N/A |
| Dependency check (cached) | <1s | Yes |
| Model training (first) | 30-60s | N/A |
| Model check (cached) | <1s | Yes |
| Service startup | 5-10s | N/A |
| **Total (first run)** | **~90-120s** | No |
| **Total (cached)** | **~10-15s** | Yes |

## Best Practices

1. **First setup**: Run once, wait for model training
2. **Daily use**: Just run the script, model is cached
3. **After updates**: Pull code, re-run script (dependencies auto-update)
4. **Clean slate**: Delete model files to force retraining
5. **Production**: Pre-train model, commit to repo (optional)

---

**The pipeline is designed to be zero-configuration. Just run it!** 🚀
