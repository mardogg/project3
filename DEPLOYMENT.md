# 🚀 Production Deployment Guide

This guide walks you through setting up a secure production web server on Digital Ocean, deploying your FastAPI Calculator application with automated CI/CD using GitHub Actions and Watchtower.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Server Setup](#server-setup)
3. [Security Hardening](#security-hardening)
4. [Docker Installation](#docker-installation)
5. [Application Deployment](#application-deployment)
6. [SSL/TLS Configuration](#ssltls-configuration)
7. [CI/CD Pipeline Setup](#cicd-pipeline-setup)
8. [Monitoring and Maintenance](#monitoring-and-maintenance)

---

## 🎯 Prerequisites

### Required Accounts and Resources

1. **Digital Ocean Account**
   - Sign up at [digitalocean.com](https://www.digitalocean.com/)
   - Apply for GitHub Student Developer Pack for $200 credit
   - Alternative: $7/month droplet

2. **Domain Name**
   - Purchase from Namecheap, GoDaddy, or use GitHub Student Pack for free .me domain
   - Configure DNS to point to your server IP

3. **Docker Hub Account**
   - Sign up at [hub.docker.com](https://hub.docker.com/)
   - Create an access token for CI/CD

4. **GitHub Repository**
   - Fork or clone this project
   - Ensure you have admin access to configure secrets

---

## 🖥️ Server Setup

### Step 1: Create Digital Ocean Droplet

1. **Log in to Digital Ocean**
   ```
   Dashboard → Create → Droplets
   ```

2. **Droplet Configuration**
   - **Distribution**: Ubuntu 22.04 LTS (recommended)
   - **Plan**: Basic ($7/month minimum)
   - **CPU**: Regular with SSD
   - **RAM**: 1GB minimum (2GB recommended for production)
   - **Region**: Choose closest to your users
   - **Authentication**: SSH keys (more secure than password)

3. **Generate SSH Key** (if you don't have one)
   ```powershell
   # On Windows (PowerShell)
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # View your public key
   Get-Content $HOME\.ssh\id_ed25519.pub
   ```

4. **Add SSH Key to Digital Ocean**
   - Copy the public key content
   - Paste in Digital Ocean → Settings → Security → SSH Keys
   - Select the key when creating your droplet

5. **Create the Droplet**
   - Click "Create Droplet"
   - Note the IP address assigned

---

## 🔒 Security Hardening

### Step 2: Initial Server Configuration

1. **Connect to Your Server**
   ```powershell
   ssh root@your_server_ip
   ```

2. **Update System Packages**
   ```bash
   apt update && apt upgrade -y
   ```

3. **Create Non-Root User**
   ```bash
   # Create user
   adduser appuser
   
   # Add to sudo group
   usermod -aG sudo appuser
   
   # Add to docker group (we'll install Docker later)
   usermod -aG docker appuser
   ```

4. **Configure SSH for Non-Root User**
   ```bash
   # Copy SSH keys to new user
   rsync --archive --chown=appuser:appuser ~/.ssh /home/appuser
   ```

5. **Configure Firewall (UFW)**
   ```bash
   # Enable UFW
   ufw enable
   
   # Allow SSH
   ufw allow OpenSSH
   
   # Allow HTTP and HTTPS
   ufw allow 80/tcp
   ufw allow 443/tcp
   
   # Check status
   ufw status
   ```

6. **Harden SSH Configuration**
   ```bash
   # Edit SSH config
   nano /etc/ssh/sshd_config
   ```
   
   **Update these settings:**
   ```
   PermitRootLogin no
   PasswordAuthentication no
   PubkeyAuthentication yes
   X11Forwarding no
   MaxAuthTries 3
   ClientAliveInterval 300
   ClientAliveCountMax 2
   ```
   
   ```bash
   # Restart SSH service
   systemctl restart sshd
   ```

7. **Configure Automatic Security Updates**
   ```bash
   apt install unattended-upgrades -y
   dpkg-reconfigure -plow unattended-upgrades
   ```

8. **Install Fail2Ban** (Prevent brute force attacks)
   ```bash
   apt install fail2ban -y
   systemctl enable fail2ban
   systemctl start fail2ban
   ```

---

## 🐳 Docker Installation

### Step 3: Install Docker and Docker Compose

1. **Install Required Packages**
   ```bash
   apt install apt-transport-https ca-certificates curl software-properties-common -y
   ```

2. **Add Docker GPG Key**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

3. **Add Docker Repository**
   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

4. **Install Docker**
   ```bash
   apt update
   apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
   ```

5. **Verify Installation**
   ```bash
   docker --version
   docker compose version
   ```

6. **Configure Docker to Start on Boot**
   ```bash
   systemctl enable docker
   systemctl start docker
   ```

7. **Add User to Docker Group**
   ```bash
   usermod -aG docker appuser
   ```

8. **Switch to Non-Root User**
   ```bash
   # Exit and reconnect
   exit
   
   # Reconnect as appuser
   ssh appuser@your_server_ip
   ```

---

## 📦 Application Deployment

### Step 4: Deploy the Application

1. **Create Application Directory**
   ```bash
   mkdir -p ~/app
   cd ~/app
   ```

2. **Create Environment File**
   ```bash
   nano .env.prod
   ```
   
   **Add your production environment variables:**
   ```env
   DOCKERHUB_USERNAME=your-dockerhub-username
   POSTGRES_USER=produser
   POSTGRES_PASSWORD=generate_strong_password_here
   POSTGRES_DB=fastapi_db
   JWT_SECRET_KEY=$(openssl rand -hex 32)
   JWT_REFRESH_SECRET_KEY=$(openssl rand -hex 32)
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   REFRESH_TOKEN_EXPIRE_DAYS=7
   BCRYPT_ROUNDS=12
   DOMAIN_NAME=your-domain.com
   ```

3. **Create Docker Compose Override**
   ```bash
   nano docker-compose.yml
   ```
   
   Copy the contents from `docker-compose.prod.yml` in your repository.

4. **Create Nginx Configuration**
   ```bash
   nano nginx.conf
   ```
   
   Copy the nginx configuration and replace `your-domain.com` with your actual domain.

5. **Log in to Docker Hub**
   ```bash
   docker login
   # Enter your Docker Hub credentials
   ```

6. **Pull and Start Services**
   ```bash
   # Load environment variables
   export $(cat .env.prod | xargs)
   
   # Pull the latest image
   docker compose pull
   
   # Start services
   docker compose up -d
   ```

7. **Verify Services are Running**
   ```bash
   docker compose ps
   docker compose logs -f web
   ```

---

## 🔐 SSL/TLS Configuration

### Step 5: Set Up HTTPS with Let's Encrypt

1. **Install Certbot**
   ```bash
   apt install certbot python3-certbot-nginx -y
   ```

2. **Obtain SSL Certificate**
   ```bash
   # Stop nginx temporarily
   docker compose stop nginx
   
   # Get certificate
   certbot certonly --standalone -d your-domain.com -d www.your-domain.com
   
   # Start nginx
   docker compose start nginx
   ```

3. **Configure Auto-Renewal**
   ```bash
   # Test renewal
   certbot renew --dry-run
   
   # Add renewal cron job
   crontab -e
   ```
   
   Add this line:
   ```
   0 3 * * * certbot renew --quiet --deploy-hook "cd ~/app && docker compose restart nginx"
   ```

4. **Verify HTTPS**
   - Visit `https://your-domain.com`
   - Check for padlock icon in browser
   - Test at [SSL Labs](https://www.ssllabs.com/ssltest/)

---

## ⚙️ CI/CD Pipeline Setup

### Step 6: Configure GitHub Actions

1. **Add Docker Hub Secrets to GitHub**
   ```
   Repository → Settings → Secrets and variables → Actions → New repository secret
   ```
   
   Add these secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Docker Hub access token

2. **Generate Docker Hub Access Token**
   - Log in to Docker Hub
   - Account Settings → Security → New Access Token
   - Copy the token

3. **Push Code to GitHub**
   ```powershell
   # On your local machine
   git add .
   git commit -m "Add CI/CD pipeline and production configuration"
   git push origin main
   ```

4. **Verify GitHub Actions**
   - Go to your repository on GitHub
   - Click "Actions" tab
   - Watch the workflow run
   - Ensure all jobs complete successfully

5. **Configure Watchtower on Server**
   
   Watchtower is already configured in `docker-compose.prod.yml` and will:
   - Check for new images every 5 minutes
   - Automatically pull and deploy updates
   - Clean up old images

---

## 📊 Monitoring and Maintenance

### Step 7: Ongoing Operations

#### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web
docker compose logs -f watchtower

# Last 100 lines
docker compose logs --tail=100 web
```

#### Check Service Status
```bash
docker compose ps
docker compose top
```

#### Update Application
The application updates automatically via Watchtower when you push to main branch:

1. Make changes locally
2. Commit and push to GitHub
3. GitHub Actions builds and pushes new image
4. Watchtower detects change and updates server

#### Manual Update
```bash
cd ~/app
docker compose pull
docker compose up -d
```

#### Backup Database
```bash
# Create backup
docker compose exec db pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup_$(date +%Y%m%d).sql

# Restore backup
docker compose exec -T db psql -U $POSTGRES_USER $POSTGRES_DB < backup_20241205.sql
```

#### Monitor Resources
```bash
# Disk usage
df -h
docker system df

# Memory usage
free -h
docker stats

# Clean up unused resources
docker system prune -a --volumes
```

---

## 🎯 SOLID Principles Implementation

This project follows SOLID principles:

### Single Responsibility Principle (SRP)
- Each module has one reason to change
- `models/` - Database schema only
- `schemas/` - Request/response validation
- `auth/` - Authentication logic
- `operations/` - Business logic

### Open/Closed Principle (OCP)
- Classes open for extension, closed for modification
- Use dependency injection for extensibility
- Strategy pattern for different calculation types

### Liskov Substitution Principle (LSP)
- Derived classes can replace base classes
- All database models inherit from Base
- All schemas inherit from BaseModel

### Interface Segregation Principle (ISP)
- Clients shouldn't depend on unused interfaces
- Separate schemas for Create, Update, Response
- Minimal dependencies in each module

### Dependency Inversion Principle (DIP)
- Depend on abstractions, not concretions
- Database session via dependency injection
- Configuration via environment variables

---

## 🎨 Design Patterns Used

### Repository Pattern
- Database access abstracted through SQLAlchemy ORM
- Separates data access from business logic

### Factory Pattern
- Token creation in `auth/jwt.py`
- User creation with password hashing

### Strategy Pattern
- Different authentication strategies (JWT, OAuth ready)
- Extensible calculation operations

### Dependency Injection
- FastAPI's `Depends()` for clean dependencies
- `get_db()` for database sessions
- `get_current_user()` for authentication

---

## 🔍 Testing

Run tests locally:
```powershell
# Install dependencies
pip install -r requirements.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test categories
pytest tests/unit/
pytest tests/integration/
pytest tests/e2e/
```

---

## 🆘 Troubleshooting

### Common Issues

**1. Cannot connect to server**
```bash
# Check SSH service
systemctl status sshd

# Check firewall
ufw status
```

**2. Docker containers not starting**
```bash
# Check logs
docker compose logs

# Check resources
docker system df
free -h
```

**3. SSL certificate issues**
```bash
# Renew certificate
certbot renew

# Check certificate
certbot certificates
```

**4. Watchtower not updating**
```bash
# Check watchtower logs
docker compose logs watchtower

# Force update
docker compose pull
docker compose up -d --force-recreate
```

**5. Database connection errors**
```bash
# Check database logs
docker compose logs db

# Verify credentials
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB
```

---

## 📚 Additional Resources

- [GitHub Student Developer Pack](https://education.github.com/pack)
- [Digital Ocean Documentation](https://docs.digitalocean.com/)
- [Docker Documentation](https://docs.docker.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Watchtower Documentation](https://containrrr.dev/watchtower/)
- [MyWebClass Hosting Guide](https://github.com/kaw393939/mywebclass_hosting)

---

## ✅ Checklist

- [ ] Digital Ocean droplet created
- [ ] SSH keys configured
- [ ] Firewall configured (UFW)
- [ ] SSH hardened
- [ ] Fail2Ban installed
- [ ] Docker installed
- [ ] Domain DNS configured
- [ ] SSL certificate obtained
- [ ] GitHub Actions secrets configured
- [ ] Application deployed
- [ ] Watchtower running
- [ ] HTTPS working
- [ ] Monitoring configured
- [ ] Backup strategy implemented

---

## 🎉 Success!

Your FastAPI Calculator application is now:
- ✅ Deployed to a secure production server
- ✅ Protected with HTTPS/TLS
- ✅ Automatically updated via CI/CD
- ✅ Monitored and maintainable
- ✅ Following SOLID principles
- ✅ Implementing design patterns

**Access your application:**
- https://your-domain.com
- Login and start calculating!

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
