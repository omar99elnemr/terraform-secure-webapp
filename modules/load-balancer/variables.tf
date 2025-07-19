# modules/load-balancer/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "public_alb_sg_id" {
  description = "ID of the public ALB security group"
  type        = string
}

variable "internal_alb_sg_id" {
  description = "ID of the internal ALB security group"
  type        = string
}