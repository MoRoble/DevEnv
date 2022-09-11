# --- networking/variables.tf--

variable "vpc_cidr" {
  type = string
}

variable "pub_cidrs" {
  type = list(any)
}

variable "app_cidrs" {
  type = list(any)
}

variable "db_cidrs" {
  type = list(any)
}

variable "pub_sn_count" {
  type = number
}

variable "app_sn_count" {
  type = number
}

variable "db_sn_count" {
  type = number
}

variable "max_subnets" {
  type = number
}

variable "access_ip" {
  type = string
}
variable "security_groups" {}


# variable "db_subnet_group" {
#   type = bool
# }

