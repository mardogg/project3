# Quick Start Script for Local Development (Windows PowerShell)
# This script helps you get the application running quickly

Write-Host "🚀 FastAPI Calculator - Quick Start" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    Write-Host "   Visit: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
    exit 1
}

# Check if Docker Compose is installed
try {
    docker compose version | Out-Null
    Write-Host "✅ Docker Compose is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed. Please update Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if .env file exists
if (-not (Test-Path .env)) {
    Write-Host "📝 Creating .env file from example..." -ForegroundColor Yellow
    if (Test-Path .env.prod.example) {
        Copy-Item .env.prod.example .env
        Write-Host "✅ Created .env file" -ForegroundColor Green
        Write-Host "⚠️  Please edit .env file with your actual values before running in production" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  .env.prod.example not found. Using defaults." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Ask user what to do
Write-Host "What would you like to do?" -ForegroundColor Cyan
Write-Host "1) Start the application"
Write-Host "2) Run tests"
Write-Host "3) Stop the application"
Write-Host "4) View logs"
Write-Host "5) Clean up (remove containers and volumes)"
Write-Host ""

$choice = Read-Host "Enter your choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🔨 Building and starting containers..." -ForegroundColor Yellow
        docker compose up --build -d
        Write-Host ""
        Write-Host "✅ Application started successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📱 Access the application:" -ForegroundColor Cyan
        Write-Host "   • Web Application: http://localhost:8000"
        Write-Host "   • API Documentation: http://localhost:8000/docs"
        Write-Host "   • Alternative API Docs: http://localhost:8000/redoc"
        Write-Host "   • PgAdmin: http://localhost:5050"
        Write-Host "     - Email: admin@example.com"
        Write-Host "     - Password: admin"
        Write-Host ""
        Write-Host "📊 View logs: docker compose logs -f" -ForegroundColor Yellow
    }
    "2" {
        Write-Host ""
        Write-Host "🧪 Running tests..." -ForegroundColor Yellow
        
        # Check if virtual environment exists
        if (-not (Test-Path venv)) {
            Write-Host "Creating virtual environment..." -ForegroundColor Yellow
            python -m venv venv
        }
        
        # Activate virtual environment
        if (Test-Path venv\Scripts\Activate.ps1) {
            & venv\Scripts\Activate.ps1
        }
        
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        pip install -r requirements.txt | Out-Null
        Write-Host ""
        
        # Run tests
        pytest --cov=app --cov-report=term-missing
    }
    "3" {
        Write-Host ""
        Write-Host "🛑 Stopping containers..." -ForegroundColor Yellow
        docker compose down
        Write-Host "✅ Containers stopped" -ForegroundColor Green
    }
    "4" {
        Write-Host ""
        Write-Host "📋 Viewing logs (Ctrl+C to exit)..." -ForegroundColor Yellow
        docker compose logs -f
    }
    "5" {
        Write-Host ""
        $confirm = Read-Host "⚠️  This will remove all containers and data. Continue? (y/n)"
        if ($confirm -eq "y") {
            Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
            docker compose down -v
            Write-Host "✅ Cleanup complete" -ForegroundColor Green
        } else {
            Write-Host "Cancelled" -ForegroundColor Yellow
        }
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Done! 🎉" -ForegroundColor Green
