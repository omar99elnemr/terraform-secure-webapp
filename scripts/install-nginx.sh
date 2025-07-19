#!/bin/bash
# scripts/install-nginx.sh - Install and configure Nginx as reverse proxy

# Update system packages
yum update -y

# Install Nginx
amazon-linux-extras install nginx1 -y

# Create Nginx configuration for reverse proxy
cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Upstream backend servers (Internal ALB)
    upstream backend {
        server ${internal_alb_dns}:80;
    }

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Proxy all other requests to backend
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Health check and connection settings
            proxy_connect_timeout 5s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # Buffer settings
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
        }

        error_page   404              /404.html;
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create a health check file
echo "nginx-proxy-ready" > /var/www/html/health

# Test Nginx configuration
nginx -t

# Create completion marker
touch /tmp/nginx-setup-complete

# Log completion
echo "Nginx reverse proxy setup completed at $(date)" >> /var/log/nginx-setup.log