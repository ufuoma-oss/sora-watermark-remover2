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
