#!/bin/bash
# scripts/install-python.sh - Install Python and Flask dependencies

# Update system packages
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install additional packages that might be needed
yum install -y git wget curl

# Upgrade pip
pip3 install --upgrade pip

# Create directory for application
mkdir -p /opt/backend-app
chown ec2-user:ec2-user /opt/backend-app

# Create completion marker
touch /tmp/python-setup-complete

# Log completion
echo "Python setup completed at $(date)" >> /var/log/python-setup.log