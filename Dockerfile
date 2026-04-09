FROM node:20-slim

# Install Python, pip, and build tools (required for better-sqlite3 if prebuilt binaries are missing)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Setup Python environment
COPY requirements.txt ./
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Build the React frontend
RUN npm run build || echo "Warning: Frontend build failed, serving static files may not work if dist doesn't exist"

# Expose port (Render dynamically sets PORT, but our app defaults to 3000 locally)
EXPOSE 3000
EXPOSE 5000

# Set environment variable so node knows it's production
ENV NODE_ENV=production

# Start the Python ML Service in the background AND the Node.js API server
CMD ["sh", "-c", "python predict_service.py > python.log 2>&1 & npx tsx server.ts"]
