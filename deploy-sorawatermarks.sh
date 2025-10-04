#!/bin/bash

echo "🌐 Deploying Sora Watermark Remover to sorawatermarks.com"
echo "========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    print_error "Please run this script from the sora-watermark-remover directory"
    exit 1
fi

print_status "Starting deployment process for sorawatermarks.com..."

# Step 1: Install prerequisites
print_status "Step 1: Checking prerequisites..."

# Check for Xcode command line tools
if ! xcode-select -p &> /dev/null; then
    print_warning "Xcode command line tools not found. Installing..."
    xcode-select --install
    print_warning "Please complete the Xcode installation and run this script again."
    exit 1
fi

# Check for Node.js
if ! command -v node &> /dev/null; then
    print_status "Installing Node.js..."
    if command -v brew &> /dev/null; then
        brew install node
    else
        print_error "Please install Node.js from https://nodejs.org/"
        exit 1
    fi
fi

# Check for Git
if ! command -v git &> /dev/null; then
    print_error "Git not found. Please install Git first."
    exit 1
fi

print_success "Prerequisites check complete!"

# Step 2: Initialize Git repository
print_status "Step 2: Setting up Git repository..."

if [ ! -d ".git" ]; then
    git init
    print_status "Git repository initialized"
fi

# Create comprehensive .gitignore
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

# Add files to git
git add .
git commit -m "Deploy to sorawatermarks.com - Sora Watermark Remover" || true

print_success "Git repository ready!"

# Step 3: Install Railway CLI
print_status "Step 3: Installing Railway CLI..."

if ! command -v railway &> /dev/null; then
    print_status "Installing Railway CLI..."
    npm install -g @railway/cli
    if [ $? -ne 0 ]; then
        print_error "Failed to install Railway CLI. Please install manually: npm install -g @railway/cli"
        exit 1
    fi
fi

print_success "Railway CLI installed!"

# Step 4: Create production environment file
print_status "Step 4: Creating production configuration..."

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

print_success "Production configuration created!"

# Step 5: Create Railway configuration
print_status "Step 5: Creating Railway configuration..."

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

# Step 6: Create deployment summary
print_status "Step 6: Creating deployment summary..."

cat > DEPLOYMENT_SUMMARY.md << 'SUMMARY'
# 🚀 Deployment Summary for sorawatermarks.com

## ✅ Completed Steps
- [x] Git repository initialized
- [x] Railway CLI installed
- [x] Production configuration created
- [x] Railway configuration created

## 🔧 Next Steps Required

### 1. GitHub Repository
```bash
# Create repository at https://github.com/new
# Name: sora-watermark-remover
# Then run:
git remote add origin https://github.com/YOUR_USERNAME/sora-watermark-remover.git
git push -u origin main
```

### 2. Railway Deployment
```bash
# Login to Railway
railway login

# Create new project
railway add

# Deploy backend
cd backend
railway up

# Deploy frontend
cd ../frontend
railway up
```

### 3. Environment Variables
Set these in Railway dashboard:

**Backend Service:**
- DATABASE_URL: (auto-generated)
- REDIS_URL: (auto-generated)
- SECRET_KEY: Generate strong secret
- AWS_ACCESS_KEY_ID: Your AWS key
- AWS_SECRET_ACCESS_KEY: Your AWS secret
- S3_BUCKET_NAME: sorawatermarks-storage
- STRIPE_SECRET_KEY: Your Stripe key
- SENDGRID_API_KEY: Your SendGrid key
- FROM_EMAIL: noreply@sorawatermarks.com

**Frontend Service:**
- REACT_APP_API_URL: https://sorawatermarks-backend.railway.app

### 4. Domain Setup
1. Go to Railway dashboard
2. Select your project
3. Go to Settings > Domains
4. Add custom domain: sorawatermarks.com
5. Update DNS records as instructed

### 5. AWS S3 Setup
1. Create bucket: sorawatermarks-storage
2. Configure CORS policy
3. Set up IAM user

### 6. Stripe Setup
1. Create Stripe account
2. Get live API keys
3. Set up webhook endpoint

### 7. SendGrid Setup
1. Create SendGrid account
2. Verify domain: sorawatermarks.com
3. Get API key

## 🌐 Final URLs
- **Website**: https://sorawatermarks.com
- **API**: https://sorawatermarks-backend.railway.app
- **API Docs**: https://sorawatermarks-backend.railway.app/docs

## 📞 Support
- Email: support@sorawatermarks.com
- Domain: sorawatermarks.com

## 💰 Estimated Costs
- Railway: $15-40/month
- AWS S3: $1-5/month
- Stripe: 2.9% + 30¢ per transaction
- SendGrid: $15-25/month
- **Total**: ~$30-70/month
SUMMARY

print_success "Deployment summary created!"

# Step 7: Final instructions
echo ""
print_success "🎉 Auto-deployment setup complete!"
echo "=========================================="
echo ""
print_status "📋 Next steps:"
echo "1. Create GitHub repository: https://github.com/new"
echo "2. Run: git remote add origin YOUR_REPO_URL"
echo "3. Run: git push -u origin main"
echo "4. Run: railway login"
echo "5. Run: railway add"
echo "6. Follow instructions in DEPLOYMENT_SUMMARY.md"
echo ""
print_status "🌐 Your domain: sorawatermarks.com"
print_status "📧 Support email: support@sorawatermarks.com"
print_status "💰 Estimated cost: $30-70/month"
echo ""
print_success "🚀 Ready to go live!"
echo ""
print_warning "⚠️  Don't forget to:"
echo "- Set up AWS S3 bucket"
echo "- Configure Stripe payments"
echo "- Set up SendGrid emails"
echo "- Update DNS records for your domain"
