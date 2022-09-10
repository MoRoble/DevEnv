##-----root/variables.tf

variable "host_os" {
  type    = string
  default = "linux"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "access_ip" {
  type = string
}