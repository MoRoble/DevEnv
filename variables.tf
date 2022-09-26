##-----root/variables.tf

variable "host_os" {
  type    = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
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
  type = list(any)
  default = [
    "Hamdi.Hassan",
    "Sadia",
    
    
  ]


}

variable "users-devops" {
  type = list(any)
  default = [
    "Mo-Roble",
    "Nuradin",
    "Moalimu"
  ]


}

variable "users-spare" {
  type = list(any)
  default = [
    "Nasir"
  ]

}
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
 variable "common-tags" {
  type = map
  
}