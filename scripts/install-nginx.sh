#!/bin/bash
# scripts/install-nginx.sh

# Update system
yum update -y

# Install nginx
yum install -y nginx

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Create a basic nginx configuration
cat > /etc/nginx/conf.d/default.conf << 'EOF'
upstream backend {
    # This will be replaced by the internal ALB DNS
    server internal-alb-dns-placeholder;
}

server {
    listen 80;
    server_name _;

    # Main application route
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeout settings
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    # Health check endpoint for ALB
    location /health {
        return 200 "Proxy OK";
        add_header Content-Type text/plain;
    }

    # Nginx status for monitoring
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 10.0.0.0/16;
        deny all;
    }
}
EOF

# Remove default nginx config
rm -f /etc/nginx/conf.d/default.conf.backup

# Test nginx configuration
nginx -t

# Restart nginx to apply changes
systemctl restart nginx

# Create a simple script to update backend upstream
cat > /home/ec2-user/update-backend.sh << 'EOF'
#!/bin/bash
# This script updates the backend upstream in nginx config
# Usage: ./update-backend.sh <internal-alb-dns>

if [ -z "$1" ]; then
    echo "Usage: $0 <internal-alb-dns>"
    exit 1
fi

INTERNAL_ALB_DNS="$1"
NGINX_CONFIG="/etc/nginx/conf.d/default.conf"

# Replace placeholder with actual internal ALB DNS
sudo sed -i "s/internal-alb-dns-placeholder/$INTERNAL_ALB_DNS/g" $NGINX_CONFIG

# Test and reload nginx
sudo nginx -t && sudo systemctl reload nginx

echo "Backend updated to: $INTERNAL_ALB_DNS"
EOF

chmod +x /home/ec2-user/update-backend.sh
chown ec2-user:ec2-user /home/ec2-user/update-backend.sh