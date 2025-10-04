# AWS Deployment Guide

## Step 1: AWS Setup
1. Create AWS account
2. Set up AWS CLI
3. Create S3 bucket for file storage
4. Set up RDS PostgreSQL database
5. Set up ElastiCache Redis

## Step 2: Deploy with ECS/Fargate
1. Create ECS cluster
2. Create task definitions for backend and frontend
3. Set up Application Load Balancer
4. Configure auto-scaling

## Step 3: Domain Setup
1. Register domain with Route 53
2. Create SSL certificate with ACM
3. Configure CloudFront CDN
4. Set up custom domain

## Step 4: Environment Variables
DATABASE_URL=postgresql://user:pass@rds-endpoint:5432/db
REDIS_URL=redis://elasticache-endpoint:6379
SECRET_KEY=production-secret-key
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
S3_BUCKET_NAME=your-bucket
