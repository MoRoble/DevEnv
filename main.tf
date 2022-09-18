###------root/main.tf ------
module "networking" {
  source       = "./networking"
  vpc_cidr     = local.vpc_cidr
  pub_sn_count = 3
  app_sn_count = 3 #var.app_account
  db_sn_count  = 3
  pub_cidrs    = [for i in range(4) : cidrsubnet(local.vpc_cidr, 4, i)]
  app_cidrs    = [for i in range(4, 8) : cidrsubnet(local.vpc_cidr, 4, i)]
  db_cidrs     = [for i in range(8, 12) : cidrsubnet(local.vpc_cidr, 4, i)]
  max_subnets  = 10
  access_ip    = var.access_ip
  # r_access_ip     = var.access_ip
  security_groups = local.security_groups
  # db_subnet_group = "true"

}




module "compute" {
  source          = "./compute"
  security_group  = module.networking.security_group
  pub_sn          = module.networking.public_subnets
  instance_count  = 1
  instance_type   = "t3.micro"
  vol_size        = "20"
  public_key_path = "/Users/Mohamed.Roble/Documents/Dev/DevEnv/devenv.pub"
  # public_key_path = "/Users/hamdi.hassan/terraform-practice/DevEnv/devenv.pub"
  key_name = "devenv"
  # instance_profile = "dev_profile"


}







