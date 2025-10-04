#!/bin/bash

echo "🌐 Simple Deploy to sorawatermarks.com"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    echo "❌ Please run this script from the sora-watermark-remover directory"
    exit 1
fi

echo "✅ Project structure verified!"

# Create .gitignore
cat > .gitignore << 'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory
coverage/

# Build directories
build/
dist/

# Temporary files
tmp/
temp/

# Railway
.railway/
GITIGNORE

echo "✅ .gitignore created!"

# Initialize Git if not already done
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git repository initialized"
fi

# Add files to git
git add .
git commit -m "Deploy to sorawatermarks.com - Sora Watermark Remover" || echo "No changes to commit"

echo "✅ Git repository ready!"

# Create production environment template
cat > .env.production << 'ENV'
# Production Environment for sorawatermarks.com
DATABASE_URL=postgresql://postgres:password@host:port/railway
REDIS_URL=redis://host:port
SECRET_KEY=CHANGE_THIS_TO_A_STRONG_SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
AWS_REGION=us-east-1
S3_BUCKET_NAME=sorawatermarks-storage

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_STRIPE_KEY
STRIPE_SECRET_KEY=sk_live_YOUR_STRIPE_SECRET
STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET

# Email Configuration
SENDGRID_API_KEY=YOUR_SENDGRID_API_KEY
FROM_EMAIL=noreply@sorawatermarks.com

# App Settings
MAX_VIDEO_SIZE_MB=500
MAX_VIDEO_DURATION_SECONDS=600
PROCESSING_TIMEOUT_SECONDS=1800

# Frontend URL
REACT_APP_API_URL=https://sorawatermarks-backend.railway.app
ENV

echo "✅ Production environment template created!"

# Create Railway configuration
cat > railway.json << 'RAILWAY'
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
RAILWAY

echo "✅ Railway configuration created!"

echo ""
echo "🎉 Setup complete for sorawatermarks.com!"
echo "=========================================="
echo ""
echo "📋 Next steps:"
echo "1. Install Node.js from https://nodejs.org/"
echo "2. Run: npm install -g @railway/cli"
echo "3. Run: railway login"
echo "4. Run: railway add"
echo "5. Set environment variables in Railway dashboard"
echo "6. Add custom domain: sorawatermarks.com"
echo ""
echo "🌐 Your domain: sorawatermarks.com"
echo "📧 Support email: support@sorawatermarks.com"
echo "💰 Estimated cost: $30-70/month"
echo ""
echo "📖 See quick-deploy.md for detailed instructions"
