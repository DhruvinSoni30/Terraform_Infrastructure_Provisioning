# Stack Name
variable "project_name" {}

# SH instance type
variable "sh_instance_type" {}

# Master instance type
variable "master_instance_type" {}

# HF instance type
variable "hf_instance_type" {}

# DP instance type
variable "dp_instance_type" {}

# IDX instance type
variable "idx_instance_type" {}

# Region
variable "region" {}

# SSH Access
variable "ssh_access" {
  type = list(string)
}

# SSH Access
variable "ui_access" {
  type = list(string)
}

# SSH Access
variable "hec_access" {
  type = list(string)
}

# SSH Access
variable "ingest_access" {
  type = list(string)
}

# Desire capacity for idx
variable "idx_desired_capacity" {
  type    = number
  default = 3
}

# Desire capacity for Master Node
variable "master_desired_capacity" {
  type    = number
  default = 1
}

# Desire capacity for SH
variable "sh_desired_capacity" {
  type    = number
  default = 1
}

# Desire capacity for HF
variable "hf_desired_capacity" {
  type    = number
  default = 1
}

# Desire capacity for DP
variable "dp_desired_capacity" {
  type    = number
  default = 1
}

# IDX volume size
variable "idx_volume_size" {
  default = 10
}

# Master volume size
variable "master_volume_size" {
  default = 10
}

# IDX volume size
variable "sh_volume_size" {
  default = 10
}

# IDX volume size
variable "hf_volume_size" {
  default = 10
}

# IDX volume size
variable "dp_volume_size" {
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
