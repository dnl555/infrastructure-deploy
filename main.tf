provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}
terraform {
  backend "remote" {
    organization = "mod-danilo"

    workspaces {
      prefix = "infrastructure-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
