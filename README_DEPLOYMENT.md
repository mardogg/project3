# 🚀 FastAPI Calculator - Production Deployment Project

A complete, production-ready FastAPI application with automated CI/CD deployment to a secure web server.

## 📖 Project Overview

This project demonstrates enterprise-level software development practices including:

- **SOLID Principles** - Clean, maintainable architecture
- **Design Patterns** - Repository, Factory, Strategy, Dependency Injection
- **CI/CD Pipeline** - Automated testing, building, and deployment
- **Security** - Hardened server, SSL/TLS, authentication
- **Containerization** - Docker & Docker Compose
- **Automated Deployment** - Watchtower for zero-downtime updates

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       GitHub Repository                      │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   Source   │  │   Tests      │  │   Dockerfile     │   │
│  │   Code     │  │              │  │                  │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │ push to main
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions CI/CD                      │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Run Tests │─▶│ Build Image  │─▶│ Push to Docker   │   │
│  │  (pytest)  │  │              │  │      Hub         │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                       Docker Hub                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     your-username/fastapi-calculator:latest         │   │
│  └─────────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │ Watchtower checks every 5 min
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                 Digital Ocean Droplet (VPS)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Nginx   │─▶│  FastAPI │  │ Postgres │  │Watchtower│  │
│  │  (443)   │  │  App     │  │ Database │  │          │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
                   Users access via
                https://your-domain.com
```

## 📂 Project Structure

```
project3/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── app/
│   ├── auth/                      # Authentication (JWT, dependencies)
│   ├── core/                      # Configuration (settings)
│   ├── models/                    # Database models (SQLAlchemy)
│   ├── operations/                # Business logic (Calculator with Strategy pattern)
│   ├── repositories/              # Repository pattern for data access
│   ├── schemas/                   # Pydantic schemas for validation
│   ├── database.py                # Database connection
│   └── main.py                    # FastAPI application
├── tests/
│   ├── unit/                      # Unit tests
│   ├── integration/               # Integration tests
│   └── e2e/                       # End-to-end tests
├── static/                        # CSS, JavaScript
├── templates/                     # HTML templates
├── docs/                          # Documentation
├── docker-compose.yml             # Development Docker setup
├── docker-compose.prod.yml        # Production Docker setup with Watchtower
├── Dockerfile                     # Production-ready Docker image
├── nginx.conf                     # Nginx reverse proxy configuration
├── requirements.txt               # Python dependencies
├── .env.prod.example              # Environment variables template
├── DEPLOYMENT.md                  # Detailed deployment guide
├── SOLID_AND_PATTERNS.md          # SOLID principles & patterns documentation
└── README.md                      # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- Git
- Digital Ocean account (or similar VPS provider)
- Domain name
- Docker Hub account

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd project3
   ```

2. **Create environment file**
   ```bash
   cp .env.prod.example .env
   # Edit .env with your local settings
   ```

3. **Run with Docker Compose**
   ```bash
   docker compose up --build
   ```

4. **Access the application**
   - Application: http://localhost:8000
   - API Docs: http://localhost:8000/docs
   - PgAdmin: http://localhost:5050

### Running Tests

```bash
# Install dependencies
pip install -r requirements.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test suites
pytest tests/unit/
pytest tests/integration/
pytest tests/e2e/
```

## 🌐 Production Deployment

### Overview

This project uses a modern CI/CD pipeline for automated deployment:

1. **Push code** to GitHub main branch
2. **GitHub Actions** automatically runs tests
3. **Docker image** is built and pushed to Docker Hub
4. **Watchtower** on your server detects the new image
5. **Automatic deployment** happens with zero downtime

### Step-by-Step Guide

See [DEPLOYMENT.md](DEPLOYMENT.md) for the complete guide covering:

1. ✅ Digital Ocean droplet setup
2. ✅ Security hardening (SSH, firewall, fail2ban)
3. ✅ Docker installation
4. ✅ SSL/TLS certificates with Let's Encrypt
5. ✅ GitHub Actions configuration
6. ✅ Watchtower setup for auto-updates
7. ✅ Monitoring and maintenance

### Quick Deployment Checklist

- [ ] Create Digital Ocean droplet (Ubuntu 22.04)
- [ ] Configure SSH keys and secure access
- [ ] Set up firewall (UFW)
- [ ] Install Docker and Docker Compose
- [ ] Configure domain DNS records
- [ ] Set up GitHub Actions secrets
- [ ] Deploy application with docker-compose
- [ ] Obtain SSL certificate
- [ ] Configure Nginx reverse proxy
- [ ] Test automated deployment

## 🏛️ SOLID Principles

This project follows SOLID principles throughout. See [SOLID_AND_PATTERNS.md](SOLID_AND_PATTERNS.md) for detailed explanations.

### Single Responsibility Principle (SRP)
- Each module has one clear purpose
- Models handle database structure only
- Schemas handle validation only
- Repositories handle data access only

### Open/Closed Principle (OCP)
- Strategy pattern for extensible calculations
- Can add new operations without modifying existing code

### Liskov Substitution Principle (LSP)
- All models can substitute their base class
- All schemas maintain base class contracts

### Interface Segregation Principle (ISP)
- Separate schemas for Create, Update, Response
- Clients only depend on what they need

### Dependency Inversion Principle (DIP)
- Depend on abstractions via FastAPI's dependency injection
- Database sessions and auth through dependencies

## 🎨 Design Patterns

### Implemented Patterns

1. **Repository Pattern** (`app/repositories/`)
   - Abstracts data access logic
   - Makes testing easier
   - Centralized database operations

2. **Strategy Pattern** (`app/operations/calculator.py`)
   - Interchangeable calculation algorithms
   - Easy to extend with new operations
   - Follows Open/Closed Principle

3. **Factory Pattern** (`app/auth/jwt.py`)
   - Token creation abstracted
   - Consistent interface for creating tokens

4. **Dependency Injection** (Throughout)
   - FastAPI's built-in DI system
   - Loose coupling between components
   - Highly testable code

5. **Singleton Pattern** (`app/core/config.py`)
   - Single settings instance
   - Efficient resource usage

See [SOLID_AND_PATTERNS.md](SOLID_AND_PATTERNS.md) for detailed implementation examples.

## 🔐 Security Features

### Application Security
- ✅ JWT-based authentication
- ✅ Password hashing with bcrypt
- ✅ CORS configuration
- ✅ SQL injection prevention (SQLAlchemy ORM)
- ✅ Input validation (Pydantic)
- ✅ Non-root Docker user

### Server Security
- ✅ SSH key authentication only
- ✅ UFW firewall configured
- ✅ Fail2Ban for brute force protection
- ✅ Automatic security updates
- ✅ SSL/TLS encryption (HTTPS)
- ✅ Security headers (HSTS, XSS protection)

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) performs:

### On Every Push/PR
- Runs full test suite with pytest
- Generates coverage reports
- Security scanning with Trivy

### On Push to Main Branch
- Builds optimized Docker image
- Pushes to Docker Hub
- Tags with commit SHA and 'latest'

### Automatic Deployment
- Watchtower monitors Docker Hub
- Automatically pulls and deploys updates
- Zero-downtime rolling updates

## 📊 Monitoring & Maintenance

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web

# Watchtower logs
docker compose logs watchtower
```

### Check Status
```bash
docker compose ps
docker compose top
```

### Database Backup
```bash
# Create backup
docker compose exec db pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql

# Restore backup
docker compose exec -T db psql -U $POSTGRES_USER $POSTGRES_DB < backup.sql
```

## 🧪 Testing Strategy

### Test Levels

1. **Unit Tests** (`tests/unit/`)
   - Test individual functions/methods
   - Fast, isolated, no external dependencies
   - Mock database and external services

2. **Integration Tests** (`tests/integration/`)
   - Test module interactions
   - Use test database
   - Validate API endpoints

3. **End-to-End Tests** (`tests/e2e/`)
   - Test complete user workflows
   - Simulate real user interactions
   - Validate entire system

### Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=app --cov-report=html

# Specific category
pytest tests/unit/
pytest tests/integration/
pytest tests/e2e/

# Specific file
pytest tests/unit/test_calculator.py

# Specific test
pytest tests/unit/test_calculator.py::test_addition
```

## 🛠️ Tech Stack

### Backend
- **FastAPI** - Modern, fast web framework
- **SQLAlchemy** - ORM for database operations
- **Pydantic** - Data validation
- **PostgreSQL** - Relational database
- **JWT** - Authentication tokens

### Frontend
- **Jinja2** - HTML templating
- **JavaScript** - Interactive features
- **CSS** - Styling

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **GitHub Actions** - CI/CD pipeline
- **Watchtower** - Automated container updates
- **Nginx** - Reverse proxy & SSL termination
- **Let's Encrypt** - Free SSL certificates

### Testing
- **pytest** - Test framework
- **pytest-cov** - Coverage reporting
- **Faker** - Test data generation

## 📚 API Endpoints

### Authentication
- `POST /register` - Create new user account
- `POST /token` - Login and get JWT token
- `POST /refresh` - Refresh access token

### Calculations
- `GET /calculations/` - List all user calculations
- `POST /calculations/` - Create new calculation
- `GET /calculations/{id}` - Get specific calculation
- `PUT /calculations/{id}` - Update calculation
- `DELETE /calculations/{id}` - Delete calculation

### Web Pages
- `GET /` - Landing page
- `GET /login` - Login page
- `GET /register` - Registration page
- `GET /dashboard` - User dashboard

See `/docs` endpoint for interactive API documentation (Swagger UI).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow SOLID principles
- Write tests for new features
- Document public APIs
- Keep functions small and focused
- Use type hints

## 📝 Environment Variables

Required environment variables (see `.env.prod.example`):

```env
# Docker Hub
DOCKERHUB_USERNAME=your-username

# Database
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=fastapi_db

# JWT
JWT_SECRET_KEY=your-secret-key-at-least-32-chars
JWT_REFRESH_SECRET_KEY=your-refresh-secret-at-least-32-chars
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Security
BCRYPT_ROUNDS=12

# Domain
DOMAIN_NAME=your-domain.com
```

## 🎓 Learning Resources

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns](https://refactoring.guru/design-patterns)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [MyWebClass Hosting Guide](https://github.com/kaw393939/mywebclass_hosting)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- FastAPI framework and community
- Digital Ocean for cloud infrastructure
- GitHub for CI/CD and hosting
- Let's Encrypt for free SSL certificates
- All open source contributors

## 📧 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check existing documentation
- Review DEPLOYMENT.md for setup help
- Review SOLID_AND_PATTERNS.md for architecture questions

---

**Made with ❤️ using SOLID principles and modern DevOps practices**
