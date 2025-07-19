# main.tf - Main Terraform configuration

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"

  project_name           = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_alb_sg_id      = module.security_groups.public_alb_sg_id
  internal_alb_sg_id    = module.security_groups.internal_alb_sg_id
}

# EC2 Instances Module
module "ec2" {
  source = "./modules/ec2"

  project_name           = var.project_name
  ami_id                = data.aws_ami.amazon_linux.id
  instance_type         = var.instance_type
  key_name              = var.key_name
  private_key_path      = var.private_key_path
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  proxy_sg_id           = module.security_groups.proxy_sg_id
  backend_sg_id         = module.security_groups.backend_sg_id
  public_target_group_arn  = module.load_balancer.public_target_group_arn
  internal_target_group_arn = module.load_balancer.internal_target_group_arn
  internal_alb_dns         = module.load_balancer.internal_alb_dns
}

# Local exec to print all IPs to file
resource "null_resource" "print_ips" {
  depends_on = [module.ec2]

  provisioner "local-exec" {
    command = <<-EOT
      echo "# All IP Addresses for ${var.project_name}" > all-ips.txt
      echo "# Generated on $(date)" >> all-ips.txt
      echo "" >> all-ips.txt
      
      echo "## Public IPs (Proxy Servers)" >> all-ips.txt
      %{for i, ip in module.ec2.proxy_public_ips~}
      echo "public-ip${i + 1} ${ip}" >> all-ips.txt
      %{endfor~}
      
      echo "" >> all-ips.txt
      echo "## Private IPs (Backend Servers)" >> all-ips.txt
      %{for i, ip in module.ec2.backend_private_ips~}
      echo "private-ip${i + 1} ${ip}" >> all-ips.txt
      %{endfor~}
      
      echo "" >> all-ips.txt
      echo "## Load Balancer DNS" >> all-ips.txt
      echo "public-alb-dns ${module.load_balancer.public_alb_dns}" >> all-ips.txt
      echo "internal-alb-dns ${module.load_balancer.internal_alb_dns}" >> all-ips.txt
    EOT
  }

  triggers = {
    proxy_ips = join(",", module.ec2.proxy_public_ips)
    backend_ips = join(",", module.ec2.backend_private_ips)
  }
}