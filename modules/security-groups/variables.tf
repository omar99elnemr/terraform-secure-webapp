# modules/security-groups/variables.tf

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

#