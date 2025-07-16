# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id = module.vpc.vpc_id
}

# Public EC2 Instances (Nginx Proxy)
module "proxy_instances" {
  source = "./modules/ec2"
  
  instance_count    = 2
  instance_type     = var.instance_type
  ami_id           = data.aws_ami.amazon_linux.id
  subnet_ids       = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.proxy_sg_id
  key_name         = var.key_name
  
  user_data = file("${path.module}/scripts/install-nginx.sh")
  
  tags = {
    Name = "${var.project_name}-proxy"
    Type = "proxy"
  }
}

# Private EC2 Instances (Backend)
module "backend_instances" {
  source = "./modules/ec2"
  
  instance_count    = 2
  instance_type     = var.instance_type
  ami_id           = data.aws_ami.amazon_linux.id
  subnet_ids       = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.backend_sg_id
  key_name         = var.key_name
  
  user_data = file("${path.module}/scripts/install-python.sh")
  
  tags = {
    Name = "${var.project_name}-backend"
    Type = "backend"
  }
}

# Public Load Balancer
module "public_alb" {
  source = "./modules/load-balancer"
  
  name            = "${var.project_name}-public-alb"
  is_internal     = false
  subnet_ids      = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.public_alb_sg_id
  vpc_id          = module.vpc.vpc_id
  target_instances = module.proxy_instances.instance_ids
  health_check_path = "/health"
}

# Internal Load Balancer
module "internal_alb" {
  source = "./modules/load-balancer"
  
  name            = "${var.project_name}-internal-alb"
  is_internal     = true
  subnet_ids      = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.internal_alb_sg_id
  vpc_id          = module.vpc.vpc_id
  target_instances = module.backend_instances.instance_ids
  health_check_path = "/health"
}

# File provisioner for backend application
resource "null_resource" "deploy_backend_app" {
  count = length(module.backend_instances.instance_ids)
  
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file(var.private_key_path)
    host                = module.backend_instances.private_ips[count.index]
    bastion_host        = module.proxy_instances.public_ips[0]
    bastion_user        = "ec2-user"
    bastion_private_key = file(var.private_key_path)
  }
  
  provisioner "file" {
    source      = "backend-app/"
    destination = "/home/ec2-user/"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo pip3 install -r /home/ec2-user/requirements.txt",
      "sudo python3 /home/ec2-user/app.py &"
    ]
  }
  
  depends_on = [module.backend_instances]
}

# Local-exec to print IPs to file
resource "null_resource" "print_ips" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "=== Public IPs ===" > all-ips.txt
      %{for i, ip in module.proxy_instances.public_ips}
      echo "public-ip${i + 1} ${ip}" >> all-ips.txt
      %{endfor}
      echo "=== Private IPs ===" >> all-ips.txt
      %{for i, ip in module.backend_instances.private_ips}
      echo "private-ip${i + 1} ${ip}" >> all-ips.txt
      %{endfor}
      echo "=== Load Balancer DNS ===" >> all-ips.txt
      echo "public-alb-dns ${module.public_alb.dns_name}" >> all-ips.txt
      echo "internal-alb-dns ${module.internal_alb.dns_name}" >> all-ips.txt
    EOT
  }
  
  depends_on = [module.proxy_instances, module.backend_instances, module.public_alb, module.internal_alb]
}