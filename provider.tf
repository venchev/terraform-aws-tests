# This code is activating the AWS provider with Terraform.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}