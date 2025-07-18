# modules/ec2/outputs.tf

output "instance_ids" {
  description = "IDs of the created instances"
  value       = aws_instance.main[*].id
}

output "public_ips" {
  description = "Public IPs of the instances"
  value       = aws_instance.main[*].public_ip
}

output "private_ips" {
  description = "Private IPs of the instances"
  value       = aws_instance.main[*].private_ip
}#