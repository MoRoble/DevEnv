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
  db_subnet_group = "true"

}




module "compute" {
  source          = "./compute"
  security_group  = module.networking.security_group
  pub_sn          = module.networking.public_subnets
  instance_count  = 1
  instance_type   = "t3.micro"
  vol_size        = "20"
  public_key_path = "/Users/hamdi.hassan/terraform-practice/DevEnv/devenv.pub"

  key_name = "devenv"
  # instance_profile = "dev_profile"


}

module "iam" {
  source      = "./iam"
  usernamedev = var.usernames-dev
  userspare   = var.users-spare
  userdevops  = var.users-devops
}


module "database" {
  source                 = "./database"
  db_engine_version      = "8.0.25"
  db_instance_class      = "db.t2.micro"
  dbname                 = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  db_identifier          = "dev-db"
  skip_db_snapshot       = true
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group
}



module "lb" {
  source = "./lb"
  # lb_count = 1
  lb_security_group       = module.networking.security_group_wordpress
  public_subnets          = module.networking.public_subnets
  tg_port                 = 8000
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  elb_healthy_threshold   = 2
  elb_unhealthy_threshold = 2
  elb_timeout             = 3
  elb_interval            = 30
  listener_port           = 8000
  listener_protocol       = "HTTP"
}
