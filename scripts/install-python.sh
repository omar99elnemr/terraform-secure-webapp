#!/bin/bash
# scripts/install-python.sh

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install Flask
pip3 install flask

# Create a simple health check script
cat > /tmp/health_check.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Make it executable
chmod +x /tmp/health_check.py

# Create systemd service for the health check
cat > /etc/systemd/system/health-check.service << 'EOF'
[Unit]
Description=Health Check Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /tmp/health_check.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the health check service
systemctl daemon-reload
systemctl enable health-check.service
systemctl start health-check.service