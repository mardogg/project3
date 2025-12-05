#!/bin/bash

# Quick Start Script for Local Development
# This script helps you get the application running quickly

set -e  # Exit on error

echo "🚀 FastAPI Calculator - Quick Start"
echo "===================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    if [ -f .env.prod.example ]; then
        cp .env.prod.example .env
        echo "✅ Created .env file"
        echo "⚠️  Please edit .env file with your actual values before running in production"
    else
        echo "⚠️  .env.prod.example not found. Using defaults."
    fi
    echo ""
fi

# Ask user what to do
echo "What would you like to do?"
echo "1) Start the application"
echo "2) Run tests"
echo "3) Stop the application"
echo "4) View logs"
echo "5) Clean up (remove containers and volumes)"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🔨 Building and starting containers..."
        docker compose up --build -d
        echo ""
        echo "✅ Application started successfully!"
        echo ""
        echo "📱 Access the application:"
        echo "   • Web Application: http://localhost:8000"
        echo "   • API Documentation: http://localhost:8000/docs"
        echo "   • Alternative API Docs: http://localhost:8000/redoc"
        echo "   • PgAdmin: http://localhost:5050"
        echo "     - Email: admin@example.com"
        echo "     - Password: admin"
        echo ""
        echo "📊 View logs: docker compose logs -f"
        ;;
    2)
        echo ""
        echo "🧪 Running tests..."
        if [ ! -d "venv" ]; then
            echo "Creating virtual environment..."
            python -m venv venv
        fi
        source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
        echo "Installing dependencies..."
        pip install -r requirements.txt > /dev/null
        echo ""
        pytest --cov=app --cov-report=term-missing
        ;;
    3)
        echo ""
        echo "🛑 Stopping containers..."
        docker compose down
        echo "✅ Containers stopped"
        ;;
    4)
        echo ""
        echo "📋 Viewing logs (Ctrl+C to exit)..."
        docker compose logs -f
        ;;
    5)
        echo ""
        read -p "⚠️  This will remove all containers and data. Continue? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            echo "🧹 Cleaning up..."
            docker compose down -v
            echo "✅ Cleanup complete"
        else
            echo "Cancelled"
        fi
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Done! 🎉"
