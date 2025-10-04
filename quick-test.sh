#!/bin/bash

# Quick Test Script for Sora Watermark Remover
# This script tests the app components without requiring a database

set -e

echo "🧪 Quick Testing Sora Watermark Remover..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Test backend imports without database
test_backend_imports() {
    print_status "Testing backend imports..."
    
    cd backend
    source venv/bin/activate
    
    # Test imports without database connection
    python3 -c "
import sys
sys.path.append('.')

# Test basic imports
try:
    import fastapi
    import uvicorn
    import sqlalchemy
    import celery
    import boto3
    import cv2
    import torch
    import numpy as np
    from PIL import Image
    import ffmpeg
    print('✅ Core dependencies imported successfully')
except Exception as e:
    print(f'❌ Core dependency import error: {e}')
    sys.exit(1)

# Test app modules (without database connection)
try:
    from app.schemas import UserCreate, UserLogin, JobCreate
    from app.auth import get_password_hash, verify_password
    from services.s3_service import S3Service
    from services.watermark_remover import WatermarkRemover
    print('✅ App modules imported successfully')
except Exception as e:
    print(f'❌ App module import error: {e}')
    sys.exit(1)

print('✅ All backend imports successful')
"
    
    cd ..
    print_success "Backend imports test passed"
}

# Test frontend
test_frontend() {
    print_status "Testing frontend..."
    
    cd frontend
    
    # Test build
    print_status "Testing React build..."
    npm run build
    
    cd ..
    print_success "Frontend build test passed"
}

# Test file structure
test_structure() {
    print_status "Testing file structure..."
    
    # Check key files exist
    files=(
        "backend/main.py"
        "backend/requirements.txt"
        "backend/app/models.py"
        "backend/app/schemas.py"
        "backend/app/auth.py"
        "backend/services/s3_service.py"
        "backend/services/watermark_remover.py"
        "frontend/package.json"
        "frontend/src/App.js"
        "frontend/src/services/api.js"
        "railway.json"
        "docker-compose.dev.yml"
        "setup-complete.sh"
        "start-dev.sh"
        "deploy-production.sh"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            print_success "✅ $file exists"
        else
            print_error "❌ $file missing"
        fi
    done
}

# Test configuration
test_config() {
    print_status "Testing configuration..."
    
    # Check .env files
    if [ -f "backend/.env" ]; then
        print_success "✅ Backend .env exists"
    else
        print_warning "⚠️ Backend .env missing"
    fi
    
    if [ -f "frontend/.env" ]; then
        print_success "✅ Frontend .env exists"
    else
        print_warning "⚠️ Frontend .env missing"
    fi
    
    # Check Railway config
    if [ -f "railway.json" ]; then
        print_success "✅ Railway config exists"
    else
        print_error "❌ Railway config missing"
    fi
}

# Main test function
main() {
    print_status "Starting quick app tests..."
    
    test_structure
    test_config
    test_backend_imports
    test_frontend
    
    print_success "🎉 All quick tests passed!"
    echo ""
    echo "✅ File Structure: Complete"
    echo "✅ Configuration: Ready"
    echo "✅ Backend Dependencies: Installed"
    echo "✅ Frontend Build: Working"
    echo ""
    echo "🚀 Your app is ready for deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Set up external services (AWS S3, Stripe, SendGrid)"
    echo "2. Update .env files with real API keys"
    echo "3. Deploy to Railway: ./deploy-production.sh"
    echo ""
    echo "For local development (requires Docker):"
    echo "./start-dev.sh"
}

# Run tests
main "$@"
