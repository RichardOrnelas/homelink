terraform {
  backend "s3" {
    bucket = "deep-seas-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      owner       = "Chainlink"
      environment = terraform.workspace
      creator     = "Terraform"
    }
  }
}
