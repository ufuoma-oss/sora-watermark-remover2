# 🚀 Quick Deploy to sorawatermarks.com

## Prerequisites (Install these first):
1. **Node.js**: Download from https://nodejs.org/
2. **Git**: Usually pre-installed on Mac
3. **Xcode Command Line Tools**: Run `xcode-select --install`

## Step 1: Install Prerequisites
```bash
# Install Xcode command line tools
xcode-select --install

# Install Node.js (if not already installed)
# Download from https://nodejs.org/ or use Homebrew:
brew install node

# Install Railway CLI
npm install -g @railway/cli
```

## Step 2: Deploy to Railway
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

## Step 3: Set Environment Variables
In Railway dashboard, set these variables:

### Backend Service:
- DATABASE_URL: (auto-generated)
- REDIS_URL: (auto-generated)
- SECRET_KEY: Generate a strong secret key
- AWS_ACCESS_KEY_ID: Your AWS access key
- AWS_SECRET_ACCESS_KEY: Your AWS secret key
- S3_BUCKET_NAME: sorawatermarks-storage
- STRIPE_SECRET_KEY: Your Stripe secret key
- SENDGRID_API_KEY: Your SendGrid API key
- FROM_EMAIL: noreply@sorawatermarks.com

### Frontend Service:
- REACT_APP_API_URL: https://sorawatermarks-backend.railway.app

## Step 4: Set Up Domain
1. Go to Railway dashboard
2. Select your project
3. Go to Settings > Domains
4. Add custom domain: sorawatermarks.com
5. Update DNS records as instructed

## Step 5: Set Up Services
1. **AWS S3**: Create bucket `sorawatermarks-storage`
2. **Stripe**: Create account and get API keys
3. **SendGrid**: Create account and verify domain

## Final Result:
- **Website**: https://sorawatermarks.com
- **API**: https://sorawatermarks-backend.railway.app
- **API Docs**: https://sorawatermarks-backend.railway.app/docs

## Cost: ~$30-70/month
