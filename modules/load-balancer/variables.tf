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
  type