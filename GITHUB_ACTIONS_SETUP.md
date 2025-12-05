# ⚙️ GitHub Actions Setup Guide

This guide walks you through setting up GitHub Actions CI/CD for your FastAPI Calculator project.

## 📋 Prerequisites

Before you begin, make sure you have:
- ✅ A GitHub account
- ✅ Your project pushed to a GitHub repository
- ✅ A Docker Hub account

---

## 🐳 Step 1: Create Docker Hub Access Token

1. **Log in to Docker Hub**
   - Go to [hub.docker.com](https://hub.docker.com/)
   - Sign in with your credentials

2. **Navigate to Security Settings**
   - Click on your username in the top-right corner
   - Select "Account Settings"
   - Click on "Security" in the left sidebar

3. **Generate New Access Token**
   - Click "New Access Token"
   - Give it a name: `github-actions-ci-cd`
   - Set permissions: **Read, Write, Delete**
   - Click "Generate"

4. **Copy the Token**
   - ⚠️ **IMPORTANT**: Copy this token immediately!
   - You won't be able to see it again
   - Store it temporarily in a secure location (you'll need it in the next step)

---

## 🔐 Step 2: Add Secrets to GitHub Repository

1. **Navigate to Your GitHub Repository**
   - Go to your project repository on GitHub
   - Example: `https://github.com/YOUR-USERNAME/project3`

2. **Open Repository Settings**
   - Click on "Settings" tab (top menu)
   - You need admin access to see this tab

3. **Navigate to Secrets and Variables**
   - In the left sidebar, expand "Secrets and variables"
   - Click on "Actions"

4. **Add DOCKERHUB_USERNAME Secret**
   - Click "New repository secret"
   - Name: `DOCKERHUB_USERNAME`
   - Value: Your Docker Hub username (e.g., `johndoe`)
   - Click "Add secret"

5. **Add DOCKERHUB_TOKEN Secret**
   - Click "New repository secret" again
   - Name: `DOCKERHUB_TOKEN`
   - Value: Paste the access token you copied from Docker Hub
   - Click "Add secret"

### ✅ Verification

You should now see two secrets listed:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

---

## 🚀 Step 3: Trigger Your First CI/CD Run

### Method 1: Push to Main Branch

```bash
# Make sure you're on the main branch
git checkout main

# Add the new CI/CD files
git add .github/workflows/ci-cd.yml
git add docker-compose.prod.yml
git add nginx.conf
git add .env.prod.example
git add DEPLOYMENT.md
git add SOLID_AND_PATTERNS.md

# Commit the changes
git commit -m "Add CI/CD pipeline and production configuration"

# Push to GitHub
git push origin main
```

### Method 2: Manual Trigger (Optional)

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Select "CI/CD Pipeline" workflow
4. Click "Run workflow"
5. Select branch: `main`
6. Click "Run workflow"

---

## 👀 Step 4: Monitor the Workflow

1. **Navigate to Actions Tab**
   - Click on "Actions" in your repository

2. **View the Running Workflow**
   - You should see your workflow running
   - Click on the workflow name to see details

3. **Check Each Job**
   The workflow has multiple jobs:
   - ✅ **test** - Runs pytest with coverage
   - ✅ **security-scan** - Scans for vulnerabilities
   - ✅ **build-and-push** - Builds and pushes Docker image
   - ✅ **notify** - Sends success notification

4. **Monitor Progress**
   - Each job shows real-time logs
   - Green checkmarks ✅ mean success
   - Red X ❌ means failure (check logs)

### Expected Output

```
✓ Run Tests (2m 30s)
  ✓ Checkout code
  ✓ Set up Python
  ✓ Install dependencies
  ✓ Run pytest with coverage
  ✓ Upload coverage reports

✓ Security Scan (1m 15s)
  ✓ Checkout code
  ✓ Run Trivy vulnerability scanner
  ✓ Upload Trivy results

✓ Build and Push Docker Image (5m 20s)
  ✓ Checkout code
  ✓ Set up Docker Buildx
  ✓ Log in to Docker Hub
  ✓ Extract metadata
  ✓ Build and push Docker image

✓ Deployment Notification (5s)
  ✓ Send success notification
```

---

## 🐛 Troubleshooting

### Problem: "Invalid credentials" when pushing to Docker Hub

**Solution:**
- Verify your Docker Hub credentials
- Check that `DOCKERHUB_USERNAME` is correct (case-sensitive)
- Regenerate Docker Hub access token if needed
- Make sure token has **Read, Write, Delete** permissions

### Problem: Tests are failing

**Solution:**
- Run tests locally first: `pytest`
- Check test output in GitHub Actions logs
- Ensure all dependencies are in `requirements.txt`
- Verify database connections in test configuration

### Problem: Workflow not triggering

**Solution:**
- Make sure you pushed to the `main` branch
- Check that `.github/workflows/ci-cd.yml` is in the repository
- Verify the YAML syntax is correct
- Check repository settings → Actions → Allow all actions

### Problem: Docker image not found after push

**Solution:**
- Verify image was successfully pushed (check Docker Hub)
- Check the image name matches your username
- Wait a few minutes for Docker Hub to index the image
- Make sure you're logged in to Docker Hub

---

## 📊 Verify Docker Hub

1. **Log in to Docker Hub**
   - Go to [hub.docker.com](https://hub.docker.com/)

2. **Check Your Repository**
   - Click on "Repositories"
   - You should see `fastapi-calculator` (or your image name)

3. **Verify Tags**
   - Click on the repository
   - Under "Tags" you should see:
     - `latest` - Most recent build
     - `main-<commit-sha>` - Tagged with commit hash

4. **Check Image Details**
   - View the image details
   - Check the last push time
   - Verify the image size is reasonable (200-500MB)

---

## 🔄 Workflow Behavior

### Automatic Triggers

The workflow runs automatically on:
- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ✅ Pull requests to `main` branch

### What Happens on Each Trigger

| Trigger | Tests Run? | Build Image? | Push to Docker Hub? |
|---------|-----------|--------------|---------------------|
| Push to `main` | ✅ Yes | ✅ Yes | ✅ Yes |
| Push to `develop` | ✅ Yes | ✅ Yes | ❌ No |
| Pull Request | ✅ Yes | ❌ No | ❌ No |

### Build Optimization

The workflow includes:
- **Layer caching** - Faster subsequent builds
- **Multi-stage builds** - Smaller image size
- **Parallel jobs** - Tests and security scans run simultaneously

---

## 🎯 Next Steps

After successfully setting up GitHub Actions:

1. **✅ Verify CI/CD is working**
   - Make a small change
   - Push to main
   - Watch the workflow run
   - Check Docker Hub for new image

2. **✅ Set up your server** (See [DEPLOYMENT.md](DEPLOYMENT.md))
   - Create Digital Ocean droplet
   - Secure the server
   - Install Docker
   - Configure domain

3. **✅ Deploy to production**
   - Set up docker-compose on server
   - Configure Watchtower
   - Deploy application
   - Get SSL certificate

4. **✅ Test automatic deployment**
   - Make a change locally
   - Push to GitHub
   - Wait for CI/CD to build
   - Watch Watchtower auto-deploy

---

## 📝 Workflow File Explanation

### Workflow Structure

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]  # Trigger on push to these branches
  pull_request:
    branches: [ main ]            # Trigger on PRs to main

env:
  DOCKER_IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/fastapi-calculator
  PYTHON_VERSION: '3.10'
```

### Jobs Overview

1. **test** - Run test suite
   - Sets up Python 3.10
   - Installs dependencies
   - Runs pytest with coverage
   - Uploads coverage reports

2. **security-scan** - Security scanning
   - Uses Trivy to scan for vulnerabilities
   - Uploads results to GitHub Security

3. **build-and-push** - Build Docker image
   - Only runs on push to `main`
   - Builds optimized Docker image
   - Pushes to Docker Hub with multiple tags
   - Uses build cache for speed

4. **notify** - Success notification
   - Runs after successful build
   - Can be extended to send Slack/email notifications

---

## 🔒 Security Best Practices

### ✅ DO:
- Use GitHub Secrets for sensitive data
- Rotate Docker Hub tokens regularly (every 6 months)
- Use read-only tokens where possible
- Review security scan results
- Keep dependencies updated

### ❌ DON'T:
- Commit secrets to the repository
- Share Docker Hub tokens publicly
- Use the same token for multiple projects
- Ignore security warnings
- Skip security updates

---

## 🎉 Success!

Once you see green checkmarks in GitHub Actions and your image appears in Docker Hub, your CI/CD pipeline is working!

**You've achieved:**
- ✅ Automated testing on every push
- ✅ Security scanning for vulnerabilities
- ✅ Automatic Docker image builds
- ✅ Seamless deployment pipeline
- ✅ Professional DevOps workflow

Next step: Deploy to your production server! See [DEPLOYMENT.md](DEPLOYMENT.md) for the complete guide.

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

## 💡 Pro Tips

1. **Badge in README**: Add a workflow status badge to your README:
   ```markdown
   ![CI/CD](https://github.com/YOUR-USERNAME/project3/workflows/CI%2FCD%20Pipeline/badge.svg)
   ```

2. **Branch Protection**: Set up branch protection rules:
   - Require status checks to pass
   - Require pull request reviews
   - Prevent force pushes

3. **Notifications**: Set up email/Slack notifications for workflow failures

4. **Caching**: Workflow already includes caching for faster builds

5. **Matrix Testing**: Consider testing against multiple Python versions:
   ```yaml
   strategy:
     matrix:
       python-version: ['3.9', '3.10', '3.11']
   ```

---

**Need Help?** Check the troubleshooting section or open an issue in your repository!
