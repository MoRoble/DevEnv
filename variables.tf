##-----root/variables.tf

variable "host_os" {
  type    = string
  default = "linux"
}

variable "aws_region" {
  type = string
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
 
variable "usernames-dev" {
  type = list
  default = [
    "Mo.Roble",
    "Hamdi.Hassan"
  ]

  
}

variable "users-devops" {
  type = list
  default = [
    "Mo-Roble",
    "Hamdi-Hassan"
  ]

  
}

variable "users-spare" {
  type = list
  default = [
    "Roble",
    "Hassan"
  ]

}