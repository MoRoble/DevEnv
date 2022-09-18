terraform {
  required_version = "~>1.1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  backend "s3" {
    bucket = "devenv-general"
    key    = "devenv/project.tfstate"

    dynamodb_table = "terraform-lock"
    region                   = "us-west-1"
  }

}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devenv01"
}