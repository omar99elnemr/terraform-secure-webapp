# modules/ec2/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "proxy_sg_id" {
  description = "Security group ID for proxy servers"
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID for backend servers"
  type        = string
}

variable "public_target_group_arn" {
  description = "ARN of the public target group"
  type        = string
}

variable "internal_target_group_arn" {
  description = "ARN of the internal target group"
  type        = string
}

variable "internal_alb_dns" {
  description = "DNS name of the internal ALB"
  type        = string
}