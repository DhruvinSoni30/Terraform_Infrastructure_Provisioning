# Using Data Source to get all Avalablility Zones in the Region
data "aws_availability_zones" "available_zones" {}

# Fetching Ubuntu 20.04 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Creating Launch Template for Master Node
resource "aws_launch_template" "master-custom-launch-template" {
  name                    = "Master-config"
  image_id                = data.aws_ami.amazon_linux_2.id
  instance_type           = var.master_instance_type
  vpc_security_group_ids  = [var.master_security_group]
  key_name                = var.key_name
  user_data               = filebase64("/Users/dhruvins/Desktop/Terraform_Infrastructure_Provisioning/Infrastructure_Definition/bin/master.sh")
  update_default_version  = true
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }
}

# Creating Auto Scaling Group for Master Node
resource "aws_autoscaling_group" "master-custom-autoscaling-group" {
  name                = "Master-auto-scalling-group"
  vpc_zone_identifier = [var.public_subnet_az1_id]
  launch_template {
    id      = aws_launch_template.master-custom-launch-template.id
    version = aws_launch_template.master-custom-launch-template.latest_version
  }
  max_size         = var.master_desired_capacity
  min_size         = var.master_desired_capacity
  desired_capacity = var.master_desired_capacity

  tag {
    key                 = "role"
    value               = "Master"
    propagate_at_launch = true
  }
  tag {
    key                 = var.env
    value               = var.type
    propagate_at_launch = true
  }
}

# Fetching Master Node
data "aws_instance" "master_instance" {
  filter {
    name   = "tag:role"
    values = ["Master"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
  depends_on = [aws_autoscaling_group.master-custom-autoscaling-group]
}

# Creating EBS volume for Master Node
resource "aws_ebs_volume" "master-volume" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  size              = var.master_volume_size
  type              = "gp2"
  tags = {
    Snapshot = "true"
    Name     = "Master Volume"
  }
}