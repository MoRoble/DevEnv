##-----root/variables.tf

variable "host_os" {
  type    = string
}

variable "aws_region" {
  default = "us-west-1"
}

variable "access_ip" {
  type = string
}

variable "app_account" {
  type    = number
  default = 3
}
variable "bucketnames" {}


#-------database variables

variable "dbname" {
  type = string
}
variable "dbuser" {
  type = string
}
variable "dbpassword" {
  type      = string
  sensitive = true
}
 variable "devtags" {
  type = map
  
}