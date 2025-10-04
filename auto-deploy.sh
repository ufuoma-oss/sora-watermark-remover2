#!/bin/bash

echo "🚀 Auto-Deploying Sora Watermark Remover to sorawatermarks.com"
echo "================================================================"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Xcode command line tools are installed
if ! xcode-select -p &> /dev/null; then
    echo "❌ Xcode command line tools not found."
    echo "📥 Installing Xcode command line tools..."
    echo "Please follow the dialog to install them, then run this script again."
    xcode-select --install
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Please install Git first."
    exit 1
fi

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing Node.js..."
    # Install Node.js via Homebrew if available
    if command -v brew &> /dev/null; then
        brew install node
    else
        echo "Please install Node.js from https://nodejs.org/"
        exit 1
    fi
fi

echo "✅ Prerequisites check complete!"

# Initialize Git repository
echo "📦 Setting up Git repository..."
if [ ! -d ".git" ]; then
    git init
    echo "Git repository initialized"
fi

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

# Coverage directory used by tools like istanbul
coverage/

# Build directories
build/
dist/

# Temporary files
tmp/
temp/
GITIGNORE

# Add all files to git
echo "📝 Adding files to Git..."
git add .
git commit -m "Initial commit - Sora Watermark Remover ready for deployment"

echo "✅ Git repository ready!"

# Create Railway configuration
echo "🚂 Creating Railway configuration..."
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

# Create production environment file
echo "⚙️ Creating production environment configuration..."
cat > .env.production << 'ENV'
# Production Environment Variables for sorawatermarks.com
DATABASE_URL=postgresql://postgres:password@host:port/railway
REDIS_URL=redis://host:port
SECRET_KEY=your-production-secret-key-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1
S3_BUCKET_NAME=sorawatermarks-storage

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_live_your-stripe-key
STRIPE_SECRET_KEY=sk_live_your-stripe-secret
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret

# Email Configuration
SENDGRID_API_KEY=your-sendgrid-api-key
FROM_EMAIL=noreply@sorawatermarks.com

# App Settings
MAX_VIDEO_SIZE_MB=500
MAX_VIDEO_DURATION_SECONDS=600
PROCESSING_TIMEOUT_SECONDS=1800

# Frontend URL
REACT_APP_API_URL=https://sorawatermarks-backend.railway.app
ENV

echo "✅ Production configuration created!"

# Create deployment instructions
cat > DEPLOY_INSTRUCTIONS.md << 'INSTRUCTIONS'
# 🚀 Deployment Instructions for sorawatermarks.com

## Step 1: GitHub Repository Setup
1. Go to https://github.com/new
2. Create repository named: sora-watermark-remover
3. Copy the repository URL
4. Run: git remote add origin YOUR_REPOSITORY_URL
5. Run: git push -u origin main

## Step 2: Railway Deployment
1. Go to https://railway.app/
2. Sign up with GitHub
3. Create new project
4. Add services:
   - PostgreSQL Database
   - Redis Database
   - Backend Service (connect to your GitHub repo)
   - Frontend Service (static site)

## Step 3: Environment Variables
Set these in Railway dashboard:

### Backend Service:
- DATABASE_URL: (auto-generated from PostgreSQL)
- REDIS_URL: (auto-generated from Redis)
- SECRET_KEY: Generate a strong secret key
- AWS_ACCESS_KEY_ID: Your AWS access key
- AWS_SECRET_ACCESS_KEY: Your AWS secret key
- AWS_REGION: us-east-1
- S3_BUCKET_NAME: sorawatermarks-storage
- STRIPE_SECRET_KEY: Your Stripe secret key
- SENDGRID_API_KEY: Your SendGrid API key
- FROM_EMAIL: noreply@sorawatermarks.com

### Frontend Service:
- REACT_APP_API_URL: https://your-backend-url.railway.app

## Step 4: Domain Setup
1. In Railway dashboard, go to your project
2. Click on Settings
3. Add Custom Domain: sorawatermarks.com
4. Update DNS records as instructed by Railway

## Step 5: AWS S3 Setup
1. Create S3 bucket: sorawatermarks-storage
2. Configure CORS policy
3. Set up IAM user with S3 permissions

## Step 6: Stripe Setup
1. Create Stripe account
2. Get API keys from dashboard
3. Set up webhook endpoint

## Step 7: SendGrid Setup
1. Create SendGrid account
2. Verify domain: sorawatermarks.com
3. Get API key

## Step 8: Test Deployment
1. Visit https://sorawatermarks.com
2. Test user registration
3. Test video upload
4. Test watermark removal

Your app will be live at: https://sorawatermarks.com
INSTRUCTIONS

echo "📋 Deployment instructions created in DEPLOY_INSTRUCTIONS.md"

# Create a quick setup script for Railway
cat > setup-railway.sh << 'RAILWAY_SETUP'
#!/bin/bash

echo "🚂 Setting up Railway deployment..."

# Install Railway CLI
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "Logging into Railway..."
railway login

# Create new project
echo "Creating Railway project..."
railway add

# Deploy
echo "Deploying to Railway..."
railway up

echo "✅ Railway deployment complete!"
echo "🌐 Your app will be available at the Railway URL"
echo "📋 Next: Set up custom domain sorawatermarks.com in Railway dashboard"
RAILWAY_SETUP

chmod +x setup-railway.sh

echo ""
echo "🎉 Auto-deployment setup complete!"
echo "=================================="
echo ""
echo "📋 Next steps:"
echo "1. Install Xcode command line tools (if not already done)"
echo "2. Run: ./auto-deploy.sh (again if needed)"
echo "3. Follow instructions in DEPLOY_INSTRUCTIONS.md"
echo "4. Or run: ./setup-railway.sh for Railway deployment"
echo ""
echo "🌐 Your domain: sorawatermarks.com"
echo "📧 Support email: support@sorawatermarks.com"
echo ""
echo "🚀 Ready to go live!"
