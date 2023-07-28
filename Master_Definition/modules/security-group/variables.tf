# VPC ID
variable "vpc_id" {
  type = string
}

# Environment
variable "env" {
  type = string
}

# Type
variable "type" {
  type = string
}

# SSH Access
variable "ssh_access" {
  type = list(string)
}
