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

# Instance type for Master Node
variable "master_instance_type" {
  type = string
}

# ID of public subnet in AZ1
variable "public_subnet_az1_id" {
  type = string
}

# Desire capacity for Master Node
variable "master_desired_capacity" {
  type = number
}

# Master Security Group
variable "master_security_group" {}

# Master Volume Size
variable "master_volume_size" {}

# IAM Instance Profile
variable "instance_profile" {}
