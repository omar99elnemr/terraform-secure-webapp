# modules/security-groups/outputs.tf

output "proxy_sg_id" {
  description = "ID of the proxy security group"
  value       = aws_security_group.proxy.id
}

output "backend_sg_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend.id
}

output "public_alb_sg_id" {
  description = "ID of the public ALB security group"
  value       = aws_security_group.public_alb.id
}

output "internal_alb_sg_id" {
  description = "ID of the internal ALB security group"
  value       = aws_security_group.internal_alb.id
}