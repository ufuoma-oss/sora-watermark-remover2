#!/bin/bash

# Production Deployment Script for Sora Watermark Remover

echo "🚀 Deploying Sora Watermark Remover to production..."

# Check if Railway CLI is available
if ! command -v railway &> /dev/null && ! npx @railway/cli --version &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "Logging in to Railway..."
if command -v railway &> /dev/null; then
    railway login
else
    npx @railway/cli login
fi

# Deploy backend
echo "Deploying backend..."
cd backend
if command -v railway &> /dev/null; then
    railway up
else
    npx @railway/cli up
fi

# Deploy frontend
echo "Deploying frontend..."
cd ../frontend
if command -v railway &> /dev/null; then
    railway up
else
    npx @railway/cli up
fi

echo "✅ Deployment complete!"
echo "🌐 Your app will be available at the Railway URLs provided above"
