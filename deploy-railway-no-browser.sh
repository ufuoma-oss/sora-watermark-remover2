#!/bin/bash

echo "🚀 Deploying Sora Watermark Remover to Railway..."

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit - Sora Watermark Remover"
fi

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📥 Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Logging into Railway..."
railway login --browserless

# Deploy
echo "🚀 Deploying to Railway..."
railway up

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app will be available at:"
echo "   Frontend: https://your-app.railway.app"
echo "   Backend: https://your-backend.railway.app"
echo ""
echo "📋 Next steps:"
echo "   1. Set up custom domain in Railway dashboard"
echo "   2. Configure environment variables"
echo "   3. Set up AWS S3 bucket"
echo "   4. Configure Stripe for payments"
echo "   5. Test your live application!"
