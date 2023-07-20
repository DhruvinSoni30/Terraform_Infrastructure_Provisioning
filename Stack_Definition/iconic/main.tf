# Creating VPC
module "vpc" {
  source = "../../Infrastructure_Definition/modules/vpc"
}

# Creating security group
module "security_groups" {
  source        = "../../Infrastructure_Definition/modules/security-groups"
  vpc_id        = module.vpc.default_vpc_id
  project_name  = var.project_name
  ssh_access    = var.ssh_access
  ui_access     = var.ui_access
  hec_access    = var.hec_access
  ingest_access = var.ingest_access
  env           = var.env
  type          = var.type
}

# Creating Load Balancer
module "alb" {
  source               = "../../Infrastructure_Definition/modules/alb"
  project_name         = var.project_name
  alb_security_group   = module.security_groups.alb_security_group_id
  public_subnet_az1_id = module.vpc.default_subnet_ids[0]
  public_subnet_az2_id = module.vpc.default_subnet_ids[1]
  public_subnet_az3_id = module.vpc.default_subnet_ids[2]
  vpc_id               = module.vpc.default_vpc_id
  env                  = var.env
  type                 = var.type
}

# Creating ASG
module "asg" {
  source                  = "../../Infrastructure_Definition/modules/auto-scaling"
  idx_instance_type       = var.idx_instance_type
  master_instance_type    = var.master_instance_type
  sh_instance_type        = var.sh_instance_type
  hf_instance_type        = var.hf_instance_type
  dp_instance_type        = var.dp_instance_type
  public_subnet_az1_id    = module.vpc.default_subnet_ids[0]
  public_subnet_az2_id    = module.vpc.default_subnet_ids[1]
  public_subnet_az3_id    = module.vpc.default_subnet_ids[2]
  master_security_group   = module.security_groups.master_security_group_id
  alb_security_group      = module.security_groups.alb_security_group_id
  sh_security_group       = module.security_groups.sh_security_group_id
  dp_security_group       = module.security_groups.dp_security_group_id
  hf_security_group       = module.security_groups.hf_security_group_id
  project_name            = var.project_name
  target_group_arn        = module.alb.target_group_arn
  master_desired_capacity = var.master_desired_capacity
  idx_desired_capacity    = var.idx_desired_capacity
  sh_desired_capacity     = var.sh_desired_capacity
  hf_desired_capacity     = var.hf_desired_capacity
  dp_desired_capacity     = var.dp_desired_capacity
  master_volume_size      = var.master_volume_size
  idx_volume_size         = var.idx_volume_size
  sh_volume_size          = var.sh_volume_size
  hf_volume_size          = var.hf_volume_size
  dp_volume_size          = var.dp_volume_size
  instance_profile        = module.iam.instance_profile
  env                     = var.env
  type                    = var.type
  key_name                = var.key_name

}

# Creating key pair
module "key_pair" {
  source   = "../../Infrastructure_Definition/modules/key_pair"
  key_name = var.key_name
}

# Creating IAM 
module "iam" {
  source = "../../Infrastructure_Definition/modules/iam"
}
