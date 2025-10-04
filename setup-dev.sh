#!/bin/bash

echo "🛠️  Setting up Sora Watermark Remover for development..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.9+ and try again."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ and try again."
    exit 1
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed. Please install PostgreSQL and try again."
    exit 1
fi

# Check if Redis is installed
if ! command -v redis-server &> /dev/null; then
    echo "❌ Redis is not installed. Please install Redis and try again."
    exit 1
fi

echo "✅ All prerequisites are installed!"

# Setup backend
echo "🐍 Setting up Python backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Create .env file
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your database and AWS credentials"
fi

cd ..

# Setup frontend
echo "⚛️  Setting up React frontend..."
cd frontend

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

cd ..

echo "✅ Development setup complete!"
echo ""
echo "🚀 To start the application:"
echo "   1. Start PostgreSQL and Redis services"
echo "   2. Update backend/.env with your configuration"
echo "   3. Run: ./start-dev.sh"
echo ""
echo "📝 Or use Docker:"
echo "   ./start.sh"
