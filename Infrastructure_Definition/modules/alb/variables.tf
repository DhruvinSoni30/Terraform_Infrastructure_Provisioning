# Environment
variable "env" {
  type = string
}

# Type
variable "type" {
  type = string
}

# Customer name
variable "project_name" {
  type = string
}

# Security group for ALB
variable "alb_security_group" {
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

# ID of pblic subnet in AZ3
variable "public_subnet_az3_id" {
  type = string
}

# VPC ID
variable "vpc_id" {
  type = string
}

# Healthcheck will be done on port 8000
variable "health_check" {
  type = map(string)
  default = {
    "timeout"             = "10"
    "interval"            = "20"
    "path"                = "/"
    "port"                = "8000"
    "unhealthy_threshold" = "2"
    "healthy_threshold"   = "3"
  }
}