# Quick Start: Set up marwacalc.com with SSL

## On Your Local Machine (Windows)

### 1. Commit and push the updated nginx configuration:

```powershell
cd "C:\Users\mmons\Project 3 IS218\project3"
git add nginx.conf quick-ssl-setup.sh DOMAIN_SETUP.md
git commit -m "Configure domain marwacalc.com with SSL support"
git push origin main
```

## On Your Digital Ocean Server

### 2. SSH into your server:

```bash
ssh root@YOUR_SERVER_IP
```

### 3. Navigate to project and pull changes:

```bash
cd ~/project3
git pull origin main
```

### 4. Run the SSL setup script:

```bash
chmod +x quick-ssl-setup.sh
sudo ./quick-ssl-setup.sh
```

The script will:
- Ask for your email (for Let's Encrypt notifications)
- Create necessary directories
- Request SSL certificates
- Configure nginx with HTTPS
- Set up auto-renewal

### 5. Test your site:

```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://marwacalc.com

# Test HTTPS
curl -I https://marwacalc.com
```

## That's it! 🎉

Your calculator app should now be live at:
- **https://marwacalc.com**
- **https://www.marwacalc.com**

## Troubleshooting

### If DNS not ready yet:
```bash
# Check DNS propagation
dig marwacalc.com +short

# Should show your server IP
# If not, wait 10-30 minutes and try again
```

### If certificate fails:
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs nginx
docker-compose -f docker-compose.prod.yml logs certbot

# Try again after DNS propagates
sudo ./quick-ssl-setup.sh
```

### View running services:
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Restart everything:
```bash
docker-compose -f docker-compose.prod.yml restart
```
