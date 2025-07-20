# Secure Web App with Public Proxy + Private Backend on AWS

This project demonstrates a secure, production-style web application architecture on AWS using Terraform. It features public proxy servers, private backend servers, and load balancing for high availability.

## 🏗️ Architecture Overview

![Architecture](imgs/architecture.png)

```
Internet → Public ALB → Nginx Proxy (Public Subnets) → Internal ALB → Backend Apps (Private Subnets)
```

## Features
- Custom VPC with public/private subnets
- Public Nginx proxy EC2s, private Flask backend EC2s
- Public & internal ALBs for secure routing
- Security groups for strict access
- Automated deployment with Terraform modules

## 🚀 Quick Start

1. **Clone & Enter Project**
   ```bash
   git clone https://github.com/omar99elnemr/terraform-secure-webapp.git
   cd terraform-secure-webapp
   ```
2. **Install & Configure AWS CLI and Terraform**
   - Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) & [Terraform](https://developer.hashicorp.com/terraform/downloads)
   - Run `aws configure` and set up your credentials
3. **Create an EC2 Key Pair**
   - This is required for SSH access and for Terraform to provision instances.
   - You can create it via AWS Console or CLI:
     ```bash
     aws ec2 create-key-pair --key-name my-terraform-key --query 'KeyMaterial' --output text > my-terraform-key.pem
     chmod 400 my-terraform-key.pem
     # Move the key to the project root if not already there
     # mv my-terraform-key.pem /path/to/terraform-secure-webapp/
     ```
4. **Prepare Backend for State**
   ```bash
   cd backend-setup
   terraform init && terraform apply
   # Copy S3 bucket and DynamoDB table outputs to ../terraform.tf
   ```
   - Update `tterraform.tf` with:
   ```hcl
   backend "s3" {
    bucket         = "ENTER YOUR GENERATED BUCKET NAME"
    .
    .
    .
    ```
5. **Set Variables**
   ```bash
   cd ..
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your key_name and private_key_path
   ```
   - Update `terraform.tfvars` with:
     ```hcl
     key_name         = "my-terraform-key"
     private_key_path = "./my-terraform-key.pem"
     ```
6. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform workspace new dev
   terraform apply
   ```
7. **Access the App**
   - Get the public ALB DNS from Terraform outputs
   - Open in your browser: `http://<public-alb-dns>`

## 📸 Verification

Below are screenshots showing the same homepage refreshed to demonstrate load balancing (note the different instance IPs/hostnames):

| Instance 1 | Instance 2 |
|--------------------------|---------------------------|
| ![Homepage1](imgs/verification01.png) | ![Homepage2](imgs/verification02.png) |

## 📝 Project Structure

```
terraform-secure-webapp/
├── backend-app/         # Flask backend app
├── backend-setup/      # Terraform backend config
├── imgs/               # Architecture & verification images
├── modules/            # Terraform modules (vpc, ec2, lb, sg)
├── scripts/            # Nginx/Python install scripts
├── main.tf, variables.tf, outputs.tf, terraform.tf, terraform.tfvars.example
└── README.md
```

## 🧩 Notes
- The app homepage shows which backend instance handled your request—refresh to see load balancing in action.
- This project was implemented by **Omar ElNemr** as a final task of the ITI's Terraform on AWS course.

---

© 2025 Omar's Secure Web App | Powered by Flask & AWS using Terraform
