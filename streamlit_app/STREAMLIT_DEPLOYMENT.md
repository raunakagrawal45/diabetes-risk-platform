# 🎯 Streamlit Deployment Guide

## Overview

Your DiaRisk AI platform now has a **Streamlit version** that runs alongside your React app. This provides an alternative interface that's easier to deploy and manage.

### What You Have:
- **React App** (Port 3000): Current full-featured interface
- **Streamlit App**: Cloud-friendly alternative interface
- **Shared Backend**: Both use the same Python ML service (Port 5000)

---

## 🚀 Local Testing

### 1. Install Streamlit Dependencies
```bash
pip install -r streamlit_requirements.txt
```

### 2. Start All Services
You need three terminal windows:

**Terminal 1 - Python ML Service (Port 5000):**
```bash
python diabetes_prediction.py
```

**Terminal 2 - Node.js Backend (Port 3000):**
```bash
npm run dev
```

**Terminal 3 - Streamlit App (Port 8501):**
```bash
streamlit run streamlit_app.py
```

### 3. Access Local App
- **Streamlit**: http://localhost:8501

---

## ☁️ Deploy to Streamlit Cloud (Free Tier)

### Prerequisites:
- GitHub account (to host your code)
- Streamlit Cloud account (free at https://streamlit.io/cloud)

### Step 1: Prepare Your Repository for Cloud

Add requirements file to root (already done):
```bash
# .streamlit/config.toml
# streamlit_app.py
# streamlit_requirements.txt
```

### Step 2: Update Config for Cloud Deployment

Since your app connects to backend services, you have two options:

**Option A: Use Cloud Version (Recommended for Production)**

Update `streamlit_app.py` to use Hugging Face Spaces or your hosted backend:

```python
# Replace localhost with your deployed backend URLs
API_URL = os.getenv("API_URL", "http://localhost:3000")
ML_URL = os.getenv("ML_URL", "http://localhost:5000")
```

**Option B: Keep Local Backend (Development)**

The current setup expects services on localhost. This works for:
- Personal use
- Team development
- Testing before full deployment

### Step 3: Push to GitHub

1. Initialize GitHub repo in your project directory:
```bash
git init
git add .
git commit -m "Add Streamlit app"
git remote add origin https://github.com/yourusername/diabetes-risk-prediction.git
git push -u origin main
```

2. Create `.gitignore`:
```
__pycache__/
*.py[cod]
*$py.class
.env
*.db
node_modules/
dist/
.DS_Store
```

### Step 4: Deploy on Streamlit Cloud

1. Go to https://share.streamlit.io
2. Click **"New app"**
3. Select your GitHub repository
4. Choose branch: `main`
5. Set file path: `streamlit_app.py`
6. Click **"Deploy!"**

### Step 5: Environment Variables (if using cloud backend)

Create `secrets.toml` in `.streamlit/`:

```toml
[connections.sql]
dialect = "sqlite"
database = "diabetes.db"

api_url = "https://your-backend.com"
ml_url = "https://your-ml-service.com"
```

---

## 📦 Deploy Backend Services

If you want full cloud deployment:

### Option 1: Deploy Node.js to Heroku/Railway

```bash
# Create Procfile
echo "web: npm start" > Procfile

git push heroku main
```

### Option 2: Deploy Python ML to Hugging Face Spaces

1. Create space at https://huggingface.co/spaces
2. Select "Docker" runtime
3. Upload your `diabetes_prediction.py`
4. Set port to 7860

### Option 3: Use Cloud Databases

Replace SQLite with PostgreSQL for production:

```python
import psycopg2
DATABASE_URL = os.getenv("DATABASE_URL")
```

---

## 📊 Feature Comparison

| Feature | React App | Streamlit App |
|---------|-----------|---------------|
| Full Control | ✅ | ⚠️ Limited |
| Deployment | Manual | One-Click |
| Customization | 🔴 High | 🟡 Medium |
| Performance | Fast | Good |
| Hosting Cost | Manual | Free Tier |
| Best For | Production | Quick Demos |

---

## 🔗 URLs After Deployment

- **Streamlit Cloud**: `https://your-username-diabetes-app.streamlit.app`
- **Your Domain**: Can be added to Streamlit Cloud Pro
- **React App**: Your hosted version (separate deployment needed)

---

## 💡 Tips for Success

1. **Test Locally First**: Always verify locally before pushing to cloud
2. **Use Environment Variables**: Keep secrets out of code
3. **Monitor Logs**: Streamlit Cloud shows real-time logs
4. **Auto-Deploy**: Streamlit auto-deploys on git push to main
5. **Cache Results**: Use `@st.cache_data` for expensive operations
6. **Handle Errors**: Add try-catch for API failures

---

## 🆘 Troubleshooting

### Backend Not Connecting
```
Error: Connection error - http://localhost:3000
```
**Solution**: Make sure Node.js server is running on port 3000

### ML Service Timeout
```
Error: timeout at http://localhost:5000/predict
```
**Solution**: Start Python diabetes_prediction.py service

### Module Import Error
```
ModuleNotFoundError: No module named 'streamlit'
```
**Solution**: 
```bash
pip install -r streamlit_requirements.txt
```

### Too Large Files
Streamlit Cloud has upload limits:
- Images: Keep under 100MB
- Sessions: Keep under 500MB
- Use caching to reduce memory

---

## 🎨 Future Enhancements

- [ ] Add user authentication
- [ ] Store predictions in cloud database
- [ ] Create mobile-responsive layout
- [ ] Add more visualization charts
- [ ] Implement real food database API
- [ ] Add social sharing features
- [ ] Create admin dashboard

---

## 📞 Support

For Streamlit help: https://docs.streamlit.io
For deployment issues: https://discuss.streamlit.io

Happy deploying! 🚀
