# Provider configuration for AWS in the "eu-west-1" region
provider "aws" {
  region = "eu-west-1"
}

# Declare Terraform config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
  }

  backend "s3" {
    key    = "dev/techronomicon/terraform.tfstate"
    region = "eu-west-1"
  }

  required_version = ">= 0.14.0"
}
