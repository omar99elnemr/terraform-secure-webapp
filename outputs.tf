# outputs.tf - Output definitions

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "proxy_public_ips" {
  description = "Public IP addresses of proxy servers"
  value       = module.ec2.proxy_public_ips
}

output "backend_private_ips" {
  description = "Private IP addresses of backend servers"
  value       = module.ec2.backend_private_ips
}

output "public_alb_dns" {
  description = "DNS name of the public Application Load Balancer"
  value       = module.load_balancer.public_alb_dns
}

output "internal_alb_dns" {
  description = "DNS name of the internal Application Load Balancer"
  value       = module.load_balancer.internal_alb_dns
}

output "public_alb_zone_id" {
  description = "Zone ID of the public Application Load Balancer"
  value       = module.load_balancer.public_alb_zone_id
}

output "nat_gateway_ip" {
  description = "Elastic IP address of NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.load_balancer.public_alb_dns}"
}