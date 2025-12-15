#!/bin/bash
# Quick SSL Setup for marwacalc.com
# Run this script on your Digital Ocean server

set -e  # Exit on any error

echo "================================================"
echo "  SSL Setup for marwacalc.com"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Get email for Let's Encrypt
read -p "Enter your email for Let's Encrypt notifications: " EMAIL

if [ -z "$EMAIL" ]; then
    echo "Email is required!"
    exit 1
fi

echo ""
echo "Step 1: Creating certbot directories..."
mkdir -p certbot/conf certbot/www
echo "✓ Directories created"

echo ""
echo "Step 2: Creating temporary HTTP-only nginx config..."
cat > nginx-temp.conf << 'EOFNGINX'
events {
    worker_connections 1024;
}

http {
    upstream fastapi {
        server web:8000;
    }

    server {
        listen 80;
        server_name marwacalc.com www.marwacalc.com;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            proxy_pass http://fastapi;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOFNGINX

# Backup original config
if [ -f "nginx.conf" ]; then
    cp nginx.conf nginx.conf.ssl-backup
    echo "✓ Original nginx.conf backed up"
fi

# Use temp config
cp nginx-temp.conf nginx.conf
echo "✓ Temporary config in place"

echo ""
echo "Step 3: Restarting nginx..."
docker-compose -f docker-compose.prod.yml restart nginx
sleep 5
echo "✓ Nginx restarted"

echo ""
echo "Step 4: Requesting SSL certificate from Let's Encrypt..."
echo "This may take a minute..."
docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --non-interactive \
    -d marwacalc.com \
    -d www.marwacalc.com

if [ $? -eq 0 ]; then
    echo "✓ SSL certificate obtained successfully!"
    
    echo ""
    echo "Step 5: Restoring full nginx config with HTTPS..."
    cp nginx.conf.ssl-backup nginx.conf
    
    echo ""
    echo "Step 6: Restarting nginx with SSL config..."
    docker-compose -f docker-compose.prod.yml restart nginx
    sleep 3
    echo "✓ Nginx restarted with SSL"
    
    echo ""
    echo "================================================"
    echo "  ✓ Setup Complete!"
    echo "================================================"
    echo ""
    echo "Your site is now available at:"
    echo "  • https://marwacalc.com"
    echo "  • https://www.marwacalc.com"
    echo ""
    echo "HTTP requests will automatically redirect to HTTPS."
    echo ""
    echo "Certificates will auto-renew every 60 days."
    echo "================================================"
    
    # Cleanup
    rm nginx-temp.conf
else
    echo ""
    echo "================================================"
    echo "  ✗ Certificate Request Failed"
    echo "================================================"
    echo ""
    echo "Possible issues:"
    echo "  1. DNS not fully propagated yet (wait 30 minutes and try again)"
    echo "  2. Firewall blocking port 80"
    echo "  3. Another service using port 80"
    echo ""
    echo "To debug:"
    echo "  • Check DNS: dig marwacalc.com +short"
    echo "  • Check nginx logs: docker-compose -f docker-compose.prod.yml logs nginx"
    echo "  • Check port 80: netstat -tulpn | grep :80"
    echo ""
    echo "Your site is still accessible via HTTP at:"
    echo "  • http://marwacalc.com"
    echo ""
    echo "Run this script again once DNS is fully propagated."
    echo "================================================"
    
    # Keep temp config since SSL failed
    rm nginx-temp.conf
    exit 1
fi
