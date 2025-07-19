# modules/ec2/outputs.tf

output "proxy_instance_ids" {
  description = "IDs of proxy instances"
  value       = aws_instance.proxy[*].id
}

output "backend_instance_ids" {
  description = "IDs of backend instances"
  value       = aws_instance.backend[*].id
}

output "proxy_public_ips" {
  description = "Public IP addresses of proxy instances"
  value       = aws_instance.proxy[*].public_ip
}

output "proxy_private_ips" {
  description = "Private IP addresses of proxy instances"
  value       = aws_instance.proxy[*].private_ip
}

output "backend_private_ips" {
  description = "Private IP addresses of backend instances"
  value       = aws_instance.backend[*].private_ip
}