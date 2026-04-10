# AI Chatbot Setup Guide

The AI Health Assistant chatbot uses Google's Gemini AI to answer questions about diabetes prevention, nutrition, exercise, and healthy lifestyle choices.

## Prerequisites

- A Google account (free)
- Google Gemini API key (free tier available)

## Step-by-Step Setup

### 1. Get Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"** or **"Get API Key"**
4. Select an existing Google Cloud project or create a new one
5. Copy the API key (it looks like: `AIzaSy...`)

**Important**: Keep your API key secure and never commit it to version control.

### 2. Configure Environment Variables

1. Locate the `.env` file in the project root (if it doesn't exist, copy from `.env.example`)
2. Open `.env` in a text editor
3. Replace `your_gemini_api_key_here` with your actual API key:

```env
GEMINI_API_KEY=AIzaSyABCDEFG1234567890_your_actual_key_here
```

4. Save the file

### 3. Restart the Server

If the server is already running, stop it (Ctrl+C) and restart:

```bash
npm run dev
```

The server will automatically load the API key from the `.env` file.

### 4. Test the Chatbot

1. Open the application at `http://localhost:3000`
2. Navigate to **"AI Assistant"** in the sidebar
3. Try asking a question like: "What are early signs of diabetes?"
4. You should receive an AI-generated response

## API Key Limits (Free Tier)

The Gemini API free tier includes:
- **60 requests per minute** (RPM)
- **1,500 requests per day per model** (RPD)
- Sufficient for development and small-scale production use

**Model Used**: `models/gemini-2.5-flash` (fast, cost-effective, high-quality)

If you exceed quota, you can:
- Wait 24 hours for daily reset
- Try alternative models like `models/gemini-2.0-flash-lite` or `models/gemini-flash-lite-latest`

[View detailed pricing](https://ai.google.dev/pricing)

## Troubleshooting

### Error: "AI service not configured"

**Problem**: The API key is not set or loaded.

**Solution**:
1. Verify the `.env` file exists in the project root
2. Check that `GEMINI_API_KEY` is set correctly
3. Ensure there are no extra spaces or quotes around the key
4. Restart the server after making changes

### Error: "Invalid API key"

**Problem**: The API key is incorrect or expired.

**Solution**:
1. Double-check you copied the complete key from Google AI Studio
2. Generate a new API key if needed
3. Ensure you're using a Gemini API key (not other Google Cloud APIs)

### Error: "Rate limit exceeded"

**Problem**: Too many requests in a short time.

**Solution**:
- Wait a minute and try again
- The free tier allows 60 requests/minute
- Consider upgrading if you need higher limits

## Security Best Practices

1. **Never commit `.env` to Git**
   - The `.gitignore` file already excludes it
   - Always use `.env.example` as a template

2. **Restrict API Key Usage**
   - In Google Cloud Console, restrict your API key to specific APIs
   - Add IP restrictions if deploying to production

3. **Rotate Keys Regularly**
   - Generate new keys periodically
   - Delete old unused keys

4. **Use Secrets Management in Production**
   - For production deployments, use proper secrets management
   - Options: Google Secret Manager, AWS Secrets Manager, Azure Key Vault
   - Never hardcode keys in your application

## Features

The AI Health Assistant provides:

- ✅ **General Health Information**: Diabetes basics, risk factors, complications
- ✅ **Nutrition Guidance**: Diet tips, meal planning, food recommendations
- ✅ **Exercise Advice**: Activity recommendations, workout safety tips
- ✅ **Prevention Strategies**: Evidence-based diabetes prevention methods
- ✅ **Symptom Education**: Warning signs and when to seek medical care
- ✅ **Context-Aware**: Remembers conversation history within a session
- ✅ **Medical Safety**: Built-in disclaimers, never diagnoses or prescribes

## Medical Disclaimer

The AI chatbot provides **general health information only** and is not a substitute for professional medical advice, diagnosis, or treatment. It will:

- ❌ **Never** diagnose medical conditions
- ❌ **Never** prescribe medications or specific dosages
- ❌ **Never** provide emergency medical guidance
- ✅ **Always** remind users to consult healthcare providers
- ✅ **Always** flag potentially sensitive medical queries

## Technical Details

- **Model**: Google Gemini 1.5 Flash
- **Context Window**: 10 most recent messages per session
- **Safety Features**: Content flagging, medical disclaimers, audit logging
- **Storage**: Conversation history stored in SQLite (for authenticated users)

## Support

If you encounter issues:
1. Check this troubleshooting guide
2. Verify your API key is valid at [Google AI Studio](https://aistudio.google.com/)
3. Check the server console for detailed error messages
4. Open an issue on GitHub with error details

## Additional Resources

- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [AI Studio](https://aistudio.google.com/)
- [Gemini API Pricing](https://ai.google.dev/pricing)
- [Google Cloud Console](https://console.cloud.google.com/)
