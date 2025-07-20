# terraform.tf - Backend and provider configuration

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  
  # Backend configuration - Update these values after running backend-setup
  backend "s3" {
    bucket         = "secure-webapp-terraform-state-a81990bd8fc651b2"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "secure-webapp-terraform-locks"
    
    # Uncomment after backend setup
    # workspace_key_prefix = "env"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
    }
  }
}