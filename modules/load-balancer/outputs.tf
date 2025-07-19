# modules/load-balancer/outputs.tf

output "public_alb_arn" {
  description = "ARN of the public Application Load Balancer"
  value       = aws_lb.public.arn
}

output "public_alb_dns" {
  description = "DNS name of the public Application Load Balancer"
  value       = aws_lb.public.dns_name
}

output "public_alb_zone_id" {
  description = "Zone ID of the public Application Load Balancer"
  value       = aws_lb.public.zone_id
}

output "internal_alb_arn" {
  description = "ARN of the internal Application Load Balancer"
  value       = aws_lb.internal.arn
}

output "internal_alb_dns" {
  description = "DNS name of the internal Application Load Balancer"
  value       = aws_lb.internal.dns_name
}

output "internal_alb_zone_id" {
  description = "Zone ID of the internal Application Load Balancer"
  value       = aws_lb.internal.zone_id
}

output "public_target_group_arn" {
  description = "ARN of the public target group"
  value       = aws_lb_target_group.public.arn
}

output "internal_target_group_arn" {
  description = "ARN of the internal target group"
  value       = aws_lb_target_group.internal.arn
}