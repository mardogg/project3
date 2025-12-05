# ✅ Deployment Checklist

Use this checklist to track your progress through the deployment process.

---

## 📋 Pre-Deployment Setup

### Account Setup
- [ ] Created GitHub account
- [ ] Created Docker Hub account
- [ ] Created Digital Ocean account
- [ ] Applied for GitHub Student Developer Pack ($200 credit)
- [ ] Purchased or obtained domain name (or using free .me domain)

### Local Development
- [ ] Cloned project repository
- [ ] Installed Docker Desktop
- [ ] Installed Git
- [ ] Tested application locally with `docker compose up --build`
- [ ] Application runs successfully at http://localhost:8000
- [ ] Can create user account and login
- [ ] Can create calculations
- [ ] All features work as expected

### Code Review
- [ ] Reviewed `SOLID_AND_PATTERNS.md`
- [ ] Understand SOLID principles implementation
- [ ] Reviewed design patterns used
- [ ] Read through main code files
- [ ] Understand project architecture

---

## 🐳 Docker Hub Setup

- [ ] Logged in to Docker Hub
- [ ] Created new repository (or will use auto-created one)
- [ ] Navigated to Account Settings → Security
- [ ] Generated new access token with Read/Write/Delete permissions
- [ ] Copied token to secure location
- [ ] Token name: `github-actions-ci-cd`

---

## 🔐 GitHub Setup

### Repository Configuration
- [ ] Forked or created repository on GitHub
- [ ] Repository is set to public or private (your choice)
- [ ] Have admin access to repository

### GitHub Secrets
- [ ] Opened repository Settings
- [ ] Navigated to Secrets and variables → Actions
- [ ] Added `DOCKERHUB_USERNAME` secret
- [ ] Added `DOCKERHUB_TOKEN` secret
- [ ] Verified both secrets appear in list

### GitHub Actions
- [ ] Created `.github/workflows/ci-cd.yml` file
- [ ] Pushed workflow file to repository
- [ ] Navigated to Actions tab
- [ ] Can see workflow listed
- [ ] Workflow has run at least once

### CI/CD Verification
- [ ] Made a small change to code
- [ ] Pushed to main branch
- [ ] Workflow triggered automatically
- [ ] All jobs completed successfully (green checkmarks)
- [ ] Docker image appeared in Docker Hub
- [ ] Image has `latest` tag
- [ ] Image has commit SHA tag

---

## 🖥️ Server Setup

### Digital Ocean Droplet
- [ ] Logged in to Digital Ocean
- [ ] Created new droplet
- [ ] Selected Ubuntu 22.04 LTS
- [ ] Selected $7/month or higher plan
- [ ] Generated SSH key pair
- [ ] Added SSH key to Digital Ocean
- [ ] Selected SSH key for droplet
- [ ] Created droplet
- [ ] Noted droplet IP address: `___________________`
- [ ] Can SSH into server as root

### Initial Security
- [ ] Updated system packages: `apt update && apt upgrade -y`
- [ ] Created non-root user: `appuser`
- [ ] Added user to sudo group
- [ ] Copied SSH keys to new user
- [ ] Tested SSH access as new user
- [ ] Cannot login as root anymore
- [ ] SSH password authentication disabled

### Firewall Setup
- [ ] Installed UFW: `apt install ufw -y`
- [ ] Allowed SSH: `ufw allow OpenSSH`
- [ ] Allowed HTTP: `ufw allow 80/tcp`
- [ ] Allowed HTTPS: `ufw allow 443/tcp`
- [ ] Enabled UFW: `ufw enable`
- [ ] Verified status: `ufw status`

### Additional Security
- [ ] Installed Fail2Ban: `apt install fail2ban -y`
- [ ] Enabled Fail2Ban service
- [ ] Configured automatic updates
- [ ] Reviewed SSH config hardening
- [ ] Disabled root login in SSH config
- [ ] Restarted SSH service

---

## 🐋 Docker Installation

- [ ] Installed required packages
- [ ] Added Docker GPG key
- [ ] Added Docker repository
- [ ] Installed Docker CE
- [ ] Verified Docker version
- [ ] Started Docker service
- [ ] Enabled Docker on boot
- [ ] Added user to docker group: `usermod -aG docker appuser`
- [ ] Logged out and back in
- [ ] Can run `docker ps` without sudo

---

## 🌐 Domain Configuration

- [ ] Purchased or obtained domain name
- [ ] Domain name: `___________________`
- [ ] Logged in to domain registrar (Namecheap, etc.)
- [ ] Configured DNS A record
  - Host: `@` → Points to server IP
  - Host: `www` → Points to server IP
- [ ] Waited for DNS propagation (5-30 minutes)
- [ ] Verified with `nslookup your-domain.com`
- [ ] Domain resolves to server IP

---

## 📦 Application Deployment

### File Setup
- [ ] Connected to server as appuser
- [ ] Created app directory: `mkdir -p ~/app`
- [ ] Changed to app directory: `cd ~/app`
- [ ] Created `.env.prod` file
- [ ] Generated secure JWT secrets (32+ characters)
- [ ] Set database credentials
- [ ] Set Docker Hub username
- [ ] Set domain name
- [ ] Created `docker-compose.yml` (copied from `docker-compose.prod.yml`)
- [ ] Created `nginx.conf` file
- [ ] Replaced `your-domain.com` with actual domain

### Docker Deployment
- [ ] Logged in to Docker Hub: `docker login`
- [ ] Loaded environment variables: `export $(cat .env.prod | xargs)`
- [ ] Pulled latest image: `docker compose pull`
- [ ] Started services: `docker compose up -d`
- [ ] Checked service status: `docker compose ps`
- [ ] All services show as "Up"
- [ ] Checked logs: `docker compose logs -f web`
- [ ] No errors in logs

### Initial Testing
- [ ] Visited http://your-ip-address:8000
- [ ] Application loads (may show security warning - normal before SSL)
- [ ] Can access home page
- [ ] Can register new user
- [ ] Can login
- [ ] Can create calculation

---

## 🔐 SSL/TLS Configuration

### Certbot Installation
- [ ] Stopped nginx temporarily: `docker compose stop nginx`
- [ ] Installed Certbot: `apt install certbot python3-certbot-nginx -y`
- [ ] Ran Certbot: `certbot certonly --standalone -d your-domain.com -d www.your-domain.com`
- [ ] Provided email address
- [ ] Agreed to terms
- [ ] Certificate obtained successfully
- [ ] Certificate location noted

### SSL Configuration
- [ ] Updated `nginx.conf` with correct domain
- [ ] Updated SSL certificate paths
- [ ] Started nginx: `docker compose start nginx`
- [ ] Visited https://your-domain.com
- [ ] See padlock icon in browser
- [ ] No security warnings
- [ ] Certificate is valid

### Auto-Renewal
- [ ] Tested renewal: `certbot renew --dry-run`
- [ ] Test successful
- [ ] Added cron job: `crontab -e`
- [ ] Added renewal line
- [ ] Saved cron configuration

---

## 🔄 Watchtower Configuration

- [ ] Watchtower service in docker-compose.yml
- [ ] Watchtower has access to Docker socket
- [ ] Watchtower configured to check every 5 minutes
- [ ] Started Watchtower: `docker compose up -d watchtower`
- [ ] Checked Watchtower logs: `docker compose logs watchtower`
- [ ] Watchtower running and checking for updates

---

## 🧪 Testing Automated Deployment

### Test 1: Manual Trigger
- [ ] Made small change locally (e.g., updated README)
- [ ] Committed change
- [ ] Pushed to GitHub main branch
- [ ] GitHub Actions workflow triggered
- [ ] Workflow completed successfully
- [ ] New image pushed to Docker Hub
- [ ] Waited 5 minutes
- [ ] Checked Watchtower logs
- [ ] Watchtower detected new image
- [ ] Watchtower pulled and deployed new image
- [ ] Application updated without manual intervention

### Test 2: End-to-End Flow
- [ ] Made code change (e.g., updated a template)
- [ ] Created branch: `git checkout -b test-deployment`
- [ ] Committed changes
- [ ] Pushed branch to GitHub
- [ ] Created pull request
- [ ] CI ran tests on PR
- [ ] Merged PR to main
- [ ] CI/CD pipeline ran
- [ ] New image built and pushed
- [ ] Watchtower auto-deployed
- [ ] Visited website
- [ ] Changes are live

---

## 🎯 Final Verification

### Application Functionality
- [ ] Can access https://your-domain.com
- [ ] SSL certificate valid (green padlock)
- [ ] Register new user account
- [ ] Login successful
- [ ] Create calculation (add, subtract, multiply, divide)
- [ ] View calculation history
- [ ] Edit calculation
- [ ] Delete calculation
- [ ] Logout
- [ ] Login again

### Security Checks
- [ ] Run SSL test: https://www.ssllabs.com/ssltest/
- [ ] SSL score is A or higher
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Security headers present
- [ ] Cannot access server as root
- [ ] Firewall active and configured
- [ ] Fail2Ban running

### Monitoring
- [ ] Can view application logs: `docker compose logs -f web`
- [ ] Can view database logs: `docker compose logs -f db`
- [ ] Can view Watchtower logs: `docker compose logs -f watchtower`
- [ ] Can view Nginx logs: `docker compose logs -f nginx`
- [ ] No critical errors in logs

### Performance
- [ ] Application responds quickly
- [ ] Database operations fast
- [ ] Pages load in < 2 seconds
- [ ] API responses < 500ms

---

## 📊 Documentation Review

- [ ] Read `DEPLOYMENT.md` completely
- [ ] Read `SOLID_AND_PATTERNS.md` completely
- [ ] Read `GITHUB_ACTIONS_SETUP.md` completely
- [ ] Read `README_DEPLOYMENT.md`
- [ ] Understand the architecture
- [ ] Can explain SOLID principles
- [ ] Can explain design patterns used
- [ ] Can explain CI/CD pipeline

---

## 📝 Deliverables

### Required for Submission
- [ ] Public URL to working application: `___________________`
- [ ] GitHub repository URL: `___________________`
- [ ] Docker Hub image URL: `___________________`
- [ ] Screenshot of working application
- [ ] Screenshot of GitHub Actions success
- [ ] Screenshot of SSL certificate
- [ ] Screenshot of Watchtower logs showing auto-deploy
- [ ] Written summary of SOLID principles used (reference `SOLID_AND_PATTERNS.md`)
- [ ] Written summary of deployment process
- [ ] Any challenges faced and solutions

### Optional Extras
- [ ] Added monitoring dashboard
- [ ] Set up database backups
- [ ] Configured custom domain email
- [ ] Added rate limiting
- [ ] Implemented caching
- [ ] Added API documentation customization
- [ ] Created custom error pages

---

## 🎓 Learning Outcomes Achieved

### Technical Skills
- [ ] Can deploy applications to cloud servers
- [ ] Understand Docker containerization
- [ ] Can configure CI/CD pipelines
- [ ] Know how to secure web servers
- [ ] Understand SSL/TLS configuration
- [ ] Can automate deployments

### Software Engineering
- [ ] Understand and apply SOLID principles
- [ ] Know design patterns and their uses
- [ ] Can write clean, maintainable code
- [ ] Understand separation of concerns
- [ ] Can architect scalable applications

### DevOps
- [ ] Understand Infrastructure as Code
- [ ] Can use GitHub Actions
- [ ] Know Docker and Docker Compose
- [ ] Understand continuous deployment
- [ ] Can monitor production applications

---

## 🏆 Final Checklist

- [ ] Application is live and accessible
- [ ] HTTPS is working with valid certificate
- [ ] Automated deployment is working
- [ ] All tests passing in CI/CD
- [ ] Server is secured
- [ ] Documentation is complete
- [ ] Can explain all components
- [ ] Ready to demonstrate to instructor
- [ ] Ready to add to portfolio
- [ ] Ready to discuss in interviews

---

## 📅 Timeline Completed

Document when you completed each major phase:

- **Local Development**: ___/___/___
- **GitHub & Docker Hub Setup**: ___/___/___
- **Server Creation**: ___/___/___
- **Security Hardening**: ___/___/___
- **Application Deployment**: ___/___/___
- **SSL Configuration**: ___/___/___
- **CI/CD Testing**: ___/___/___
- **Final Verification**: ___/___/___

**Total Time Invested**: _______ hours

---

## 🎉 Congratulations!

If you've checked all boxes, you've successfully:
✅ Built a production-ready application
✅ Implemented SOLID principles
✅ Set up automated CI/CD
✅ Deployed to a secure server
✅ Configured automatic updates
✅ Gained real-world DevOps experience

**You're ready to showcase this project!** 🚀

---

## 📧 Support

If stuck on any step:
1. ✓ Review the relevant documentation file
2. ✓ Check the troubleshooting section
3. ✓ Search for the error message
4. ✓ Ask in class or office hours
5. ✓ Review course materials

**Good luck!** You've got this! 💪
