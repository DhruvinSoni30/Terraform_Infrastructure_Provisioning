# Environment
variable "env" {
  type = string
}

# Type
variable "type" {
  type = string
}

# Key 
variable "key_name" {}

# Instance type for Indexers
variable "idx_instance_type" {
  type = string
}

# Instance type for Master Node
variable "master_instance_type" {
  type = string
}

# Instance type for Search Head
variable "sh_instance_type" {
  type = string
}

# Instance type for Forwarder
variable "hf_instance_type" {
  type = string
}

# Instance type for Deployer
variable "dp_instance_type" {
  type = string
}

# ID of public subnet in AZ1
variable "public_subnet_az1_id" {
  type = string
}

# ID of public subnet in AZ2
variable "public_subnet_az2_id" {
  type = string
}

# ID of public subnet in AZ3
variable "public_subnet_az3_id" {
  type = string
}

# Desire capacity for Indexers
variable "idx_desired_capacity" {
  type = number
}

# Desire capacity for Master Node
variable "master_desired_capacity" {
  type = number
}

# Desire capacity for Search Head
variable "sh_desired_capacity" {
  type = number
}

# Desire capacity for Forwarder
variable "hf_desired_capacity" {
  type = number
}

# Desire capacity for Deployer
variable "dp_desired_capacity" {
  type = number
}

# Indexers security Group
variable "alb_security_group" {}

# Master Security Group
variable "master_security_group" {}

# Stack name
variable "project_name" {}

# Target Group ARN
variable "target_group_arn" {}

# Search Head Security Group
variable "sh_security_group" {}

# Forwarder Security Group
variable "hf_security_group" {}

# Deployer Security Group
variable "dp_security_group" {}

# Indexers Volume Size
variable "idx_volume_size" {}

# Master Volume Size
variable "master_volume_size" {}

# IDX Volume Size
variable "sh_volume_size" {}

# IDX Volume Size
variable "hf_volume_size" {}

# IDX Volume Size
variable "dp_volume_size" {}

# IAM Instance Profile
variable "instance_profile" {}
