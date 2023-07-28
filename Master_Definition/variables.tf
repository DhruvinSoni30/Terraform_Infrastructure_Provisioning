# Master instance type
variable "master_instance_type" {}

# Region
variable "region" {}

# SSH Access
variable "ssh_access" {
  type = list(string)
}

# Desire capacity for Master Node
variable "master_desired_capacity" {
  type    = number
  default = 1
}

# Master name
variable "project_name" {
  type    = string
}

# Master volume size
variable "master_volume_size" {
  default = 10
}

# Environment
variable "env" {
  type    = string
  default = "Prod"
}

# Type
variable "type" {
  type    = string
  default = "Production"
}

# Key 
variable "key_name" {
  default = "Demo-key"
}
