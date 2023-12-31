# create ASG for master node
module "asg" {
  source                  = "./modules/auto-scaling"
  master_instance_type    = var.master_instance_type
  public_subnet_az1_id    = module.vpc.default_subnet_ids[0]
  master_security_group   = module.security_groups.master_security_group_id
  master_desired_capacity = var.master_desired_capacity
  master_volume_size      = var.master_volume_size
  instance_profile        = module.iam.instance_profile
  env                     = var.env
  type                    = var.type
  key_name                = var.key_name
}

# create security group
module "security_groups" {
  source     = "./modules/security-group"
  vpc_id     = module.vpc.default_vpc_id
  ssh_access = var.ssh_access
  env        = var.env
  type       = var.type
}

# create VPC
module "vpc" {
  source = "../Infrastructure_Definition/modules/vpc/"
}

# Create IAM 
module "iam" {
  source       = "../Infrastructure_Definition/modules/iam"
  project_name = var.project_name
}