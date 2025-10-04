#!/bin/bash

# Complete Setup Script for Sora Watermark Remover
# This script will set up the entire application for development and deployment

set -e

echo "🚀 Setting up Sora Watermark Remover..."

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

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js from https://nodejs.org/"
        exit 1
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3."
        exit 1
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed. Please install pip3."
        exit 1
    fi
    
    print_success "All requirements are installed"
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd backend
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cat > .env << EOF
# Database
DATABASE_URL=postgresql://user:password@localhost/sora_watermark_remover

# Redis
REDIS_URL=redis://localhost:6379

# Security
SECRET_KEY=dev-secret-key-change-in-production-$(openssl rand -hex 32)

# AWS S3 (Update these with your actual values)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1
S3_BUCKET_NAME=sorawatermarks-storage

# Stripe (Update these with your actual values)
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key

# SendGrid (Update these with your actual values)
SENDGRID_API_KEY=your-sendgrid-api-key
FROM_EMAIL=noreply@sorawatermarks.com

# Frontend URL
FRONTEND_URL=http://localhost:3000
EOF
        print_warning "Created .env file with default values. Please update with your actual API keys."
    fi
    
    cd ..
    print_success "Backend setup complete"
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd frontend
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cat > .env << EOF
# API Configuration
REACT_APP_API_URL=http://localhost:8000

# Stripe (Update with your actual publishable key)
REACT_APP_STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
EOF
        print_warning "Created .env file with default values. Please update with your actual API keys."
    fi
    
    cd ..
    print_success "Frontend setup complete"
}

# Create Docker Compose for local development
create_docker_compose() {
    print_status "Creating Docker Compose configuration for local development..."
    
    cat > docker-compose.dev.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: sora_watermark_remover
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@postgres:5432/sora_watermark_remover
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  celery:
    build: ./backend
    environment:
      - DATABASE_URL=postgresql://user:password@postgres:5432/sora_watermark_remover
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app
    command: celery -A app.celery_app worker --loglevel=info

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm start

volumes:
  postgres_data:
EOF
    
    print_success "Docker Compose configuration created"
}

# Create development start script
create_dev_script() {
    print_status "Creating development start script..."
    
    cat > start-dev.sh << 'EOF'
#!/bin/bash

# Development Start Script for Sora Watermark Remover

echo "🚀 Starting Sora Watermark Remover in development mode..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start services with Docker Compose
echo "Starting services..."
docker-compose -f docker-compose.dev.yml up --build

echo "✅ Services started!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
EOF
    
    chmod +x start-dev.sh
    print_success "Development start script created"
}

# Create production deployment script
create_deploy_script() {
    print_status "Creating production deployment script..."
    
    cat > deploy-production.sh << 'EOF'
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
EOF
    
    chmod +x deploy-production.sh
    print_success "Production deployment script created"
}

# Main setup function
main() {
    print_status "Starting complete setup for Sora Watermark Remover..."
    
    check_requirements
    setup_backend
    setup_frontend
    create_docker_compose
    create_dev_script
    create_deploy_script
    
    print_success "🎉 Setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Update the .env files with your actual API keys:"
    echo "   - backend/.env"
    echo "   - frontend/.env"
    echo ""
    echo "2. For local development:"
    echo "   ./start-dev.sh"
    echo ""
    echo "3. For production deployment:"
    echo "   ./deploy-production.sh"
    echo ""
    echo "🔧 Required services to set up:"
    echo "   - AWS S3 bucket: sorawatermarks-storage"
    echo "   - Stripe account for payments"
    echo "   - SendGrid account for emails"
    echo ""
    echo "📚 Documentation:"
    echo "   - API Docs: http://localhost:8000/docs (after starting)"
    echo "   - Frontend: http://localhost:3000 (after starting)"
    echo ""
    print_success "Happy coding! 🚀"
}

# Run main function
main "$@"
