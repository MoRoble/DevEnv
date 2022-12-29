#### providers.tf

provider "aws" {
  #   shared_config_files      = ["/Users/tf_user/.aws/conf"]
  region                   = "us-west-2"
  shared_credentials_files = [("~/.aws/credentials")]
  # shared_credentials_file = "/Users/M ROBLE/.aws/credentials"
  profile = "devenv01"
  # profile = "arday1"
}