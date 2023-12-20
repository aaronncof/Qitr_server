terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "s3" {
    bucket = "totalcloudmx-clients-terraform-state"
    region = "us-east-1"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  alias = "client"
  region  = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account-id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "dev-ops"
  region  = "us-east-1"
}