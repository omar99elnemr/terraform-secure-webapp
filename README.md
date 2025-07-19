# Secure Web App with Public Proxy + Private Backend on AWS

This project demonstrates a secure web application architecture deployed on AWS using Terraform. The infrastructure includes public proxy servers and private backend servers with load balancing and high availability.

## Architecture Overview

![Architecture](architecture.png)
```
Internet → Public ALB → Nginx Proxy (Public Subnets) → Internal ALB → Backend Apps (Private Subnets)
```
### Components
- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **Public Subnets**: Host Nginx reverse proxy servers
- **Private Subnets**: Host backend application servers
- **NAT Gateway**: Provides internet access for private subnets
- **Application Load Balancers**: Public ALB for external traffic, Internal ALB for backend routing
- **Security Groups**: Network-level security controls
- **EC2 Instances**: Proxy and backend servers


## 📁 Project Structure

```
terraform-secure-webapp/
├── README.md                    # This documentation file
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.tf                 # Backend and provider configuration
├── terraform.tfvars.example     # Example variables file
├── .gitignore                   # Git ignore patterns
├── architecture.png             # Architecture diagram
├── all-ips.txt                  # Generated IP addresses file
├── modules/
│   ├── vpc/                     # VPC module
│   │   ├── main.tf              # VPC resources
│   │   ├── variables.tf         # VPC variables
│   │   └── outputs.tf           # VPC outputs
│   ├── security-groups/         # Security groups module
│   │   ├── main.tf              # Security group resources
│   │   ├── variables.tf         # Security group variables
│   │   └── outputs.tf           # Security group outputs
│   ├── ec2/                     # EC2 instances module
│   │   ├── main.tf              # EC2 resources
│   │   ├── variables.tf         # EC2 variables
│   │   └── outputs.tf           # EC2 outputs
│   └── load-balancer/           # Load balancer module
│       ├── main.tf              # ALB resources
│       ├── variables.tf         # ALB variables
│       └── outputs.tf           # ALB outputs
├── backend-app/
│   ├── app.py                   # Flask backend application
│   └── requirements.txt         # Python dependencies
├── backend-setup/               # Terraform backend setup
│   ├── main.tf                  # S3 and DynamoDB resources
│   ├── variables.tf             # Backend setup variables
│   └── outputs.tf               # Backend setup outputs
└── scripts/
    ├── install-nginx.sh         # Nginx installation script
    └── install-python.sh        # Python installation script
```


## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

### 1. AWS CLI
Install and configure AWS CLI with your credentials:
```bash
# Install AWS CLI (if not already installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter default output format (json)
```

### 2. Terraform
Install Terraform (version 1.0+):
```bash
# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
```

### 3. AWS Key Pair
Create an AWS EC2 Key Pair for SSH access:
```bash
# Create key pair using AWS CLI
aws ec2 create-key-pair --key-name my-terraform-key --query 'KeyMaterial' --output text > my-terraform-key.pem

# Set proper permissions
chmod 400 my-terraform-key.pem
```

**Note**: AWS key pair creation and S3 bucket setup are included in the deployment process.

## 🚀 Step-by-Step Deployment Guide

### Step 1: Clone the Repository
```bash
git clone https://github.com/omar99elnemr/terraform-secure-webapp.git
cd terraform-secure-webapp
```

### Step 2: Set up Terraform Backend
Create an S3 bucket for state storage:
```bash
# Navigate to backend setup directory
cd backend-setup

# Initialize and apply
terraform init
terraform apply

# Note the outputs - you'll need these values
```

### Step 3: Update Main Project and Migrate
Update your main `terraform.tf` with the output values:

```hcl
# terraform.tf (update with actual values from backend-setup outputs)
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "secure-webapp-terraform-state-a1b2c3d4e5f6g7h8"  # From output
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "secure-webapp-terraform-locks"  # From output
  }
}
```

### Step 4: Configure Variables
```bash
cd ..
# Copy the example file and customize it
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your specific values
vim terraform.tfvars
```

**Example terraform.tfvars content:**
```hcl
# AWS Configuration
aws_region   = "us-east-1"
project_name = "secure-webapp"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Availability Zones and Subnets
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# Instance Configuration
instance_type = "t3.micro"

# CHANGE THESE TO YOUR VALUES
key_name         = "my-terraform-key"
private_key_path = "./my-terraform-key.pem"
```

### Step 5: Initialize and Create Workspace
```bash
terraform init
terraform workspace new dev
terraform workspace select dev
```

### Step 6: Deploy Infrastructure
```bash
terraform plan
terraform apply
```

### Step 7: Access the Application
- Get the public load balancer DNS from outputs
- Access via browser: `http://<public-alb-dns>`


## 🔍 Deployment Details

### 1. VPC and Networking
- **Custom VPC**: 10.0.0.0/16 CIDR with DNS resolution enabled
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 with auto-assign public IPs
- **Private Subnets**: 10.0.3.0/24, 10.0.4.0/24 with NAT gateway routing
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: Single NAT gateway in first public subnet
- **Route Tables**: Separate routing for public and private subnets

### 2. Security Groups
- **Public ALB SG**: Allows HTTP/HTTPS from internet
- **Proxy SG**: Allows HTTP/HTTPS from ALB, SSH from anywhere
- **Internal ALB SG**: Allows HTTP from proxy servers
- **Backend SG**: Allows Flask port (5000) from Internal ALB, SSH from proxy

### 3. EC2 Instances
- **Proxy Instances**: 
  - Amazon Linux 2 in public subnets
  - Nginx reverse proxy configuration
  - Auto-configured to forward to internal ALB
- **Backend Instances**: 
  - Amazon Linux 2 in private subnets
  - Python 3 and Flask installation
  - Application deployed via file provisioner

### 4. Load Balancers
- **Public ALB**: 
  - Internet-facing
  - Routes HTTP traffic to proxy instances
  - Health checks on root path
- **Internal ALB**: 
  - Internal only
  - Routes traffic from proxy to backend instances
  - Health checks on /health endpoint

### 5. Application Details
- **Flask Backend**: 
  - Runs on port 5000
  - Multiple endpoints: /, /health, /api/status, /api/test
  - Returns server information for load balancing verification
- **Nginx Proxy**: 
  - Configured as reverse proxy
  - Health endpoint on /health
  - Forwards all traffic to internal ALB

## 🧪 Testing the Deployment

### 1. Check Generated Files
```bash
# View all IP addresses
cat all-ips.txt

# Example output:
# public-ip1 54.123.45.67
# public-ip2 34.567.89.12
# private-ip1 10.0.3.100
# private-ip2 10.0.4.200
# public-alb-dns secure-webapp-public-alb-123456789.us-east-1.elb.amazonaws.com
```

### 2. Test Public Access
```bash
# Test via public ALB
curl http://<public-alb-dns>

# Expected response includes backend server hostname
# Multiple requests should show different backend servers
```

### 3. Verify Load Balancing
```bash
# Multiple curl requests to see different backend responses
for i in {1..5}; do
  curl -s http://<public-alb-dns> | grep hostname
  sleep 1
done
```

### 4. Health Checks
```bash
# Check health endpoints
curl http://<public-alb-dns>/health
curl http://<public-alb-dns>/api/status
curl http://<public-alb-dns>/api/test
```

### 5. SSH Access
```bash
# SSH to proxy server (bastion)
ssh -i my-terraform-key.pem ec2-user@<proxy-public-ip>

# SSH to backend server via proxy (bastion)
ssh -i my-terraform-key.pem -J ec2-user@<proxy-public-ip> ec2-user@<backend-private-ip>
```

## 🧹 Cleanup

To destroy the infrastructure:
```bash
# Destroy main infrastructure
terraform destroy

# Destroy backend setup (if desired)
cd backend-setup
terraform destroy
```
**⚠️ Warning**: This will permanently delete all resources including the S3 bucket with state files.


## 🐛 Troubleshooting

### Common Issues

1. **Key Pair Not Found**
   ```bash
   # Ensure key pair exists in correct region
   aws ec2 describe-key-pairs --key-names my-terraform-key
   ```

2. **Permission Denied**
   ```bash
   # Check key file permissions
   chmod 400 my-terraform-key.pem
   ```

3. **Health Check Failures**
   ```bash
   # Check if application is running on backend
   ssh -i key.pem -J ec2-user@proxy-ip ec2-user@backend-ip
   ps aux | grep python
   ```

4. **State Lock Issues**
   ```bash
   # Force unlock if needed (use with caution)
   terraform force-unlock <lock-id>
   ```

## 🔧 Key Features

### Infrastructure as Code
- **Modular Design**: Custom Terraform modules for reusability
- **Remote State**: S3 backend with state locking using DynamoDB
- **Workspaces**: Separate environments (dev, staging, prod)
- **Data Sources**: Uses AWS AMI data source for latest Amazon Linux 2

### Security
- **Network Isolation**: Private subnets for backend servers
- **Security Groups**: Least privilege access controls
- **NAT Gateway**: Secure internet access for private instances
- **Bastion Host Pattern**: SSH access via proxy servers

### High Availability
- **Multi-AZ Deployment**: Resources across multiple availability zones
- **Load Balancing**: Application Load Balancers for traffic distribution
- **Health Checks**: Automated health monitoring for all components
- **Auto Scaling Ready**: Infrastructure prepared for auto scaling groups

### Automation
- **Provisioners**: 
  - Remote provisioners for software installation
  - File provisioners for application deployment
  - Local-exec for IP address logging
- **User Data**: Automated software installation via cloud-init
- **Template Files**: Dynamic configuration generation

## 💰 Cost Optimization

- **Instance Types**: Uses t3.micro for cost-effectiveness (Free Tier eligible)
- **Single NAT Gateway**: Shared across AZs (can be scaled for HA)
- **No Reserved Instances**: Pay-as-you-go model
- **Termination Protection**: Disabled for easy cleanup

## 🔒 Security Considerations

### Network Security
1. **Private Subnets**: Backend servers have no direct internet access
2. **Security Groups**: Implement least privilege principle
3. **NACLs**: Additional network-level security (can be added)

### Access Control
1. **SSH Access**: Only through bastion host pattern
2. **Application Access**: Only through load balancers
3. **IAM Roles**: Can be added for EC2 instance permissions

### Data Protection
1. **Encryption**: S3 state bucket encrypted
2. **Secrets Management**: Use AWS Secrets Manager for sensitive data
3. **SSL/TLS**: Can be configured for HTTPS termination


**Happy Deploying! 🚀**