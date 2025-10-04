#!/bin/bash

echo "🚀 Starting Sora Watermark Remover in development mode..."

# Check if virtual environment exists
if [ ! -d "backend/venv" ]; then
    echo "❌ Virtual environment not found. Run ./setup-dev.sh first."
    exit 1
fi

# Start Redis in background
echo "🔴 Starting Redis..."
redis-server --daemonize yes

# Start PostgreSQL (assuming it's already running)
echo "🐘 PostgreSQL should be running..."

# Start backend
echo "🐍 Starting backend server..."
cd backend
source venv/bin/activate
python main.py &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "⏳ Waiting for backend to start..."
sleep 5

# Start frontend
echo "⚛️  Starting frontend server..."
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

echo "✅ Development servers started!"
echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   API Documentation: http://localhost:8000/docs"
echo ""
echo "🛑 To stop the servers:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo "   redis-cli shutdown"

# Keep script running
wait
