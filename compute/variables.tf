# --- compute/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "security_group" {}
variable "pub_sn" {}
variable "vol_size" {}
variable "public_key_path" {}
variable "key_name" {}
# variable "instance_profile" {}
# variable "iam_role" {}
variable "host_os" {
  type    = string
  default = "linux"
}
variable "db_subnet_group" {}