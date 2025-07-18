# modules/load-balancer/variables.tf

variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "is_internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_instances" {
  description = "List of target instance IDs"
  type        = list(string)
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

#Github Repo test