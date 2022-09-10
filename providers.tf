terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  #   shared_config_files      = ["/Users/tf_user/.aws/conf"]
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "devenv01"
}

# Configure the AWS Provider
# provider "aws" {
#   region = "us-east-1"
# }
