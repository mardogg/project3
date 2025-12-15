#!/bin/bash

# SSL Setup Script for marwacalc.com
# This script will obtain SSL certificates from Let's Encrypt

echo "Starting SSL setup for marwacalc.com..."

# Create directories for certbot
mkdir -p certbot/conf
mkdir -p certbot/www

# Create a temporary nginx config for initial certificate request
cat > nginx-initial.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream fastapi {
        server web:8000;
    }

    # HTTP Server for certificate validation
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
EOF

# Backup the original nginx config
cp nginx.conf nginx.conf.backup

# Use the temporary config
cp nginx-initial.conf nginx.conf

# Restart nginx with the temporary config
docker-compose -f docker-compose.prod.yml restart nginx

echo "Waiting for nginx to restart..."
sleep 5

# Request the SSL certificate
echo "Requesting SSL certificate from Let's Encrypt..."
docker-compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email your-email@example.com \
    --agree-tos \
    --no-eff-email \
    -d marwacalc.com \
    -d www.marwacalc.com

if [ $? -eq 0 ]; then
    echo "SSL certificate obtained successfully!"
    
    # Restore the full nginx config with HTTPS
    cp nginx.conf.backup nginx.conf
    
    # Restart nginx with the full config
    docker-compose -f docker-compose.prod.yml restart nginx
    
    echo "Setup complete! Your site should now be accessible at https://marwacalc.com"
else
    echo "Failed to obtain SSL certificate. Please check your DNS settings."
    echo "Make sure marwacalc.com and www.marwacalc.com point to this server's IP."
    
    # Keep the temporary config since SSL failed
    echo "Keeping HTTP-only configuration until SSL is resolved."
fi

# Clean up
rm nginx-initial.conf
