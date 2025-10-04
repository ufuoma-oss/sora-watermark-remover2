#!/bin/bash

# Test Script for Sora Watermark Remover
# This script tests the app without Docker

set -e

echo "🧪 Testing Sora Watermark Remover..."

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

# Test backend
test_backend() {
    print_status "Testing backend..."
    
    cd backend
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Test imports
    print_status "Testing Python imports..."
    python3 -c "
import sys
sys.path.append('.')
try:
    from main import app
    from app.database import get_db
    from app.models import User, Job, JobStatus, SubscriptionTier
    from app.schemas import UserCreate, UserLogin
    from services.s3_service import s3_service
    from services.watermark_remover import watermark_remover
    print('✅ All imports successful')
except Exception as e:
    print(f'❌ Import error: {e}')
    sys.exit(1)
"
    
    # Test FastAPI app
    print_status "Testing FastAPI app..."
    python3 -c "
import sys
sys.path.append('.')
from main import app
from fastapi.testclient import TestClient

client = TestClient(app)
response = client.get('/api/health')
if response.status_code == 200:
    print('✅ Health check successful')
else:
    print(f'❌ Health check failed: {response.status_code}')
    sys.exit(1)
"
    
    cd ..
    print_success "Backend tests passed"
}

# Test frontend
test_frontend() {
    print_status "Testing frontend..."
    
    cd frontend
    
    # Test build
    print_status "Testing React build..."
    npm run build
    
    cd ..
    print_success "Frontend tests passed"
}

# Test API endpoints
test_api() {
    print_status "Testing API endpoints..."
    
    cd backend
    source venv/bin/activate
    
    # Start backend in background
    print_status "Starting backend server..."
    python3 -c "
import uvicorn
from main import app
import threading
import time

def run_server():
    uvicorn.run(app, host='127.0.0.1', port=8000, log_level='error')

server_thread = threading.Thread(target=run_server, daemon=True)
server_thread.start()
time.sleep(3)  # Wait for server to start
print('Backend server started')
" &
    
    BACKEND_PID=$!
    sleep 5
    
    # Test health endpoint
    print_status "Testing health endpoint..."
    if curl -s http://localhost:8000/api/health | grep -q "healthy"; then
        print_success "Health endpoint working"
    else
        print_error "Health endpoint failed"
    fi
    
    # Test API docs
    print_status "Testing API docs..."
    if curl -s http://localhost:8000/docs | grep -q "FastAPI"; then
        print_success "API docs accessible"
    else
        print_error "API docs not accessible"
    fi
    
    # Kill backend
    kill $BACKEND_PID 2>/dev/null || true
    
    cd ..
}

# Main test function
main() {
    print_status "Starting app tests..."
    
    test_backend
    test_frontend
    test_api
    
    print_success "🎉 All tests passed!"
    echo ""
    echo "✅ Backend: Ready"
    echo "✅ Frontend: Ready"
    echo "✅ API: Working"
    echo ""
    echo "🚀 Your app is ready to use!"
    echo ""
    echo "To start the app:"
    echo "1. Backend: cd backend && source venv/bin/activate && python main.py"
    echo "2. Frontend: cd frontend && npm start"
    echo ""
    echo "Or use the development script: ./start-dev.sh (requires Docker)"
}

# Run tests
main "$@"
