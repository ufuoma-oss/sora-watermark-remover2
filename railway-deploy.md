# Railway Deployment Guide

## Step 1: Prepare for Railway
1. Go to https://railway.app/
2. Sign up with GitHub
3. Connect your repository

## Step 2: Deploy Backend
1. Create new project
2. Add PostgreSQL database
3. Add Redis database
4. Deploy backend with these environment variables:

DATABASE_URL=postgresql://postgres:password@host:port/railway
REDIS_URL=redis://host:port
SECRET_KEY=your-production-secret-key
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name

## Step 3: Deploy Frontend
1. Create another project for frontend
2. Set environment variable:
REACT_APP_API_URL=https://your-backend-url.railway.app

## Step 4: Custom Domain
1. Go to project settings
2. Add custom domain
3. Update DNS records
