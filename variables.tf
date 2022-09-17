##-----root/variables.tf

# variable "host_os" {
#   type    = string
#   default = "linux"
# }

variable "aws_region" {
  default = "us-west-2"
}

variable "access_ip" {
  type = string
}

variable "app_account" {
  type    = number
  default = 3
}
# variable "main_sgs" {}

# variable "pub_sn" {}