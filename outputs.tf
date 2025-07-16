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
  description = "Public IPs of proxy instances"
  value       = module.proxy_instances.public_ips
}

output "backend_private_ips" {
  description = "Private IPs of backend instances"
  value       = module.backend_instances.private_ips
}

output "public_load_balancer_dns" {
  description = "DNS name of the public load balancer"
  value       = module.public_alb.dns_name
}

output "internal_load_balancer_dns" {
  description = "DNS name of the internal load balancer"
  value       = module.internal_alb.dns_name
}