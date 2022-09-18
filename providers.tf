terraform {
  required_version = "~>1.1.0"

  backend "s3" {
    bucket = "devenv-general"
    key    = "devenv/project.tfstate"

    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devenv01"
}