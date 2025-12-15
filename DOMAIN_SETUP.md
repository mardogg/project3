# Domain Setup Guide for marwacalc.com

This guide will help you configure your application to run on `marwacalc.com` with SSL/HTTPS.

## Prerequisites
- ✅ DNS records configured (A records for @ and www pointing to your server IP)
- ✅ Application deployed on Digital Ocean
- ⏳ DNS propagation (may take up to 48 hours, but usually 5-30 minutes)

## Step 1: Verify DNS Propagation

Before proceeding, verify your DNS is working:

```bash
# Check if your domain resolves to the correct IP
nslookup marwacalc.com
nslookup www.marwacalc.com

# Or use dig
dig marwacalc.com +short
dig www.marwacalc.com +short
```

Both should return your Digital Ocean server's IP address.

## Step 2: Update Configuration Files

The nginx configuration has been updated to use `marwacalc.com` instead of `your-domain.com`.

## Step 3: Deploy Updated Configuration

On your Digital Ocean server, run these commands:

```bash
# Navigate to your project directory
cd ~/project3

# Pull the latest changes (if using git)
git pull origin main

# Or manually upload the updated nginx.conf file
# You can use scp: scp nginx.conf user@your-server-ip:~/project3/

# Restart nginx to apply changes
docker-compose -f docker-compose.prod.yml restart nginx
```

## Step 4: Obtain SSL Certificate

### Option A: Manual Certificate Request (Recommended)

```bash
# SSH into your Digital Ocean server
ssh root@your-server-ip

# Navigate to project directory
cd ~/project3

# Create certbot directories
mkdir -p certbot/conf certbot/www

# First, temporarily modify nginx to only listen on port 80
# Edit nginx.conf and comment out the HTTPS server block

# Restart nginx
docker-compose -f docker-compose.prod.yml restart nginx

# Request certificate
docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email YOUR_EMAIL@example.com \
    --agree-tos \
    --no-eff-email \
    -d marwacalc.com \
    -d www.marwacalc.com

# After successful certificate generation, restore the full nginx.conf
# Then restart nginx
docker-compose -f docker-compose.prod.yml restart nginx
```

### Option B: Use the Setup Script

```bash
# Make the script executable
chmod +x setup-ssl.sh

# Edit the script to add your email
nano setup-ssl.sh
# Change: --email your-email@example.com
# To:     --email YOUR_ACTUAL_EMAIL@example.com

# Run the script
./setup-ssl.sh
```

## Step 5: Test Your Domain

After completing the steps above:

1. Visit `http://marwacalc.com` - should redirect to HTTPS
2. Visit `https://marwacalc.com` - should work with valid SSL
3. Visit `http://www.marwacalc.com` - should redirect to HTTPS
4. Visit `https://www.marwacalc.com` - should work with valid SSL

## Troubleshooting

### DNS Not Resolving
```bash
# Wait for DNS propagation (usually takes 5-30 minutes)
# Check propagation status at: https://dnschecker.org
```

### Certificate Request Fails
- Ensure ports 80 and 443 are open in your firewall
- Verify DNS is pointing to your server
- Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`

### HTTPS Not Working
```bash
# Check if certificates exist
ls -la certbot/conf/live/marwacalc.com/

# Check nginx logs
docker-compose -f docker-compose.prod.yml logs nginx

# Restart all services
docker-compose -f docker-compose.prod.yml restart
```

### Port 80 Already in Use
```bash
# Check what's using port 80
sudo netstat -tulpn | grep :80

# Stop the service if needed
sudo systemctl stop apache2  # or whatever service is running
```

## Certificate Auto-Renewal

The certbot container is configured to automatically renew certificates. It checks twice daily and renews certificates that are within 30 days of expiration.

## Testing SSL Configuration

```bash
# Test SSL configuration
curl -I https://marwacalc.com

# Check SSL certificate details
openssl s_client -connect marwacalc.com:443 -servername marwacalc.com
```

## Quick Commands Reference

```bash
# View all running containers
docker-compose -f docker-compose.prod.yml ps

# Restart nginx only
docker-compose -f docker-compose.prod.yml restart nginx

# View nginx logs
docker-compose -f docker-compose.prod.yml logs -f nginx

# Restart all services
docker-compose -f docker-compose.prod.yml restart

# Force certificate renewal (testing)
docker-compose -f docker-compose.prod.yml run --rm certbot renew --force-renewal
```

## Next Steps

Once everything is working:

1. ✅ Update any hardcoded URLs in your application to use `marwacalc.com`
2. ✅ Configure Google OAuth (if used) to include `https://marwacalc.com` as authorized redirect
3. ✅ Update any API documentation with the new domain
4. ✅ Set up monitoring for certificate expiration
5. ✅ Consider adding additional DNS records (like email, if needed)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review nginx and certbot logs
3. Verify DNS settings in your domain registrar
4. Ensure firewall rules allow ports 80 and 443
