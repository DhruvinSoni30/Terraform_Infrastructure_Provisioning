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

# Creating Launch Template for IDX
resource "aws_launch_template" "idx-custom-launch-template" {
  name                    = "${var.project_name}-idx-config"
  image_id                = data.aws_ami.amazon_linux_2.id
  instance_type           = var.idx_instance_type
  vpc_security_group_ids  = [var.alb_security_group]
  key_name                = var.key_name
  user_data               = filebase64("/Users/dhruvins/Desktop/Terraform_Infrastructure_Provisioning/Infrastructure_Definition/bin/puppet.sh")
  update_default_version  = true
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }
}

# Creating Auto Scaling group for IDX
resource "aws_autoscaling_group" "idx-custom-autoscaling-group" {
  name                = "${var.project_name}-idx-auto-scalling-group"
  vpc_zone_identifier = [var.public_subnet_az1_id, var.public_subnet_az2_id, var.public_subnet_az3_id]
  launch_template {
    id      = aws_launch_template.idx-custom-launch-template.id
    version = aws_launch_template.idx-custom-launch-template.latest_version
  }
  max_size          = var.idx_desired_capacity
  min_size          = var.idx_desired_capacity
  desired_capacity  = var.idx_desired_capacity
  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "role"
    value               = "idx"
    propagate_at_launch = true
  }
  tag {
    key                 = "PuppetEnv"
    value               = "production"
    propagate_at_launch = true
  }
  tag {
    key                 = var.env
    value               = var.type
    propagate_at_launch = true
  }
  tag {
    key                 = "stack_name"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# Creating Launch Template for SH
resource "aws_launch_template" "sh-custom-launch-template" {
  name                    = "${var.project_name}-sh-config"
  image_id                = data.aws_ami.amazon_linux_2.id
  instance_type           = var.sh_instance_type
  vpc_security_group_ids  = [var.sh_security_group]
  key_name                = var.key_name
  user_data               = filebase64("/Users/dhruvins/Desktop/Terraform_Infrastructure_Provisioning/Infrastructure_Definition/bin/puppet.sh")
  update_default_version  = true
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }
}

# Creating Auto Scaling group for SH
resource "aws_autoscaling_group" "sh-custom-autoscaling-group" {
  name                = "${var.project_name}-sh-auto-scalling-group"
  vpc_zone_identifier = [var.public_subnet_az1_id]
  launch_template {
    id      = aws_launch_template.sh-custom-launch-template.id
    version = aws_launch_template.sh-custom-launch-template.latest_version
  }
  max_size         = var.sh_desired_capacity
  min_size         = var.sh_desired_capacity
  desired_capacity = var.sh_desired_capacity

  tag {
    key                 = "role"
    value               = "SH"
    propagate_at_launch = true
  }
  tag {
    key                 = "PuppetEnv"
    value               = "production"
    propagate_at_launch = true
  }
  tag {
    key                 = var.env
    value               = var.type
    propagate_at_launch = true
  }
  tag {
    key                 = "stack_name"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# Creating Launch Template for HF
resource "aws_launch_template" "hf-custom-launch-template" {
  name                    = "${var.project_name}-hf-config"
  image_id                = data.aws_ami.amazon_linux_2.id
  instance_type           = var.hf_instance_type
  vpc_security_group_ids  = [var.hf_security_group]
  key_name                = var.key_name
  user_data               = filebase64("/Users/dhruvins/Desktop/Terraform_Infrastructure_Provisioning/Infrastructure_Definition/bin/puppet.sh")
  update_default_version  = true
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }
}

# Creating Auto Scalling group for HF
resource "aws_autoscaling_group" "hf-custom-autoscaling-group" {
  name                = "${var.project_name}-hf-auto-scalling-group"
  vpc_zone_identifier = [var.public_subnet_az2_id]
  launch_template {
    id      = aws_launch_template.hf-custom-launch-template.id
    version = aws_launch_template.hf-custom-launch-template.latest_version
  }
  max_size         = var.hf_desired_capacity
  min_size         = var.hf_desired_capacity
  desired_capacity = var.hf_desired_capacity

  tag {
    key                 = "role"
    value               = "HF"
    propagate_at_launch = true
  }
  tag {
    key                 = "PuppetEnv"
    value               = "production"
    propagate_at_launch = true
  }
  tag {
    key                 = var.env
    value               = var.type
    propagate_at_launch = true
  }
  tag {
    key                 = "stack_name"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# Creating Launch Template for DP
resource "aws_launch_template" "dp-custom-launch-template" {
  name                    = "${var.project_name}-dp-config"
  image_id                = data.aws_ami.amazon_linux_2.id
  instance_type           = var.dp_instance_type
  vpc_security_group_ids  = [var.dp_security_group]
  key_name                = var.key_name
  user_data               = filebase64("/Users/dhruvins/Desktop/Terraform_Infrastructure_Provisioning/Infrastructure_Definition/bin/puppet.sh")
  update_default_version  = true
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = var.instance_profile
  }
}

# Creating Auto Scalling group for DP
resource "aws_autoscaling_group" "dp-custom-autoscaling-group" {
  name                = "${var.project_name}-dp-auto-scalling-group"
  vpc_zone_identifier = [var.public_subnet_az3_id]
  launch_template {
    id      = aws_launch_template.dp-custom-launch-template.id
    version = aws_launch_template.dp-custom-launch-template.latest_version
  }
  max_size         = var.dp_desired_capacity
  min_size         = var.dp_desired_capacity
  desired_capacity = var.dp_desired_capacity

  tag {
    key                 = "role"
    value               = "DP"
    propagate_at_launch = true
  }
  tag {
    key                 = "PuppetEnv"
    value               = "production"
    propagate_at_launch = true
  }
  tag {
    key                 = var.env
    value               = var.type
    propagate_at_launch = true
  }
  tag {
    key                 = "stack_name"
    value               = var.project_name
    propagate_at_launch = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Creating IAM Role
resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Fetching IAM policy document for DLM
data "aws_iam_policy_document" "dlm_lifecycle" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

# Creating IAM policy
resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "${var.project_name}-dlm-lifecycle-policy"
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

# Creating DLM Policy
resource "aws_dlm_lifecycle_policy" "example" {
  description        = "example DLM lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}

# Creating EIPs for Indexers
resource "aws_eip" "idx-eips" {
  count  = aws_autoscaling_group.idx-custom-autoscaling-group.desired_capacity
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.project_name}-Indexers-EIP"
  }
}

# Creating EIP for Search Head
resource "aws_eip" "sh-eip" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.project_name}-Searchhead-EIP"
  }
}

# Creating EIP for Deployer
resource "aws_eip" "dp-eip" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.project_name}-Deployer-EIP"
  }
}

# Fetching Search Head
data "aws_instance" "sh_instance" {
  filter {
    name   = "tag:role"
    values = ["SH"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  filter {
    name   = "tag:stack_name"
    values = ["${var.project_name}"]
  }
  depends_on = [aws_autoscaling_group.sh-custom-autoscaling-group]
}

# Associating EIP to Search Head
resource "aws_eip_association" "sh_eip_association" {
  instance_id         = data.aws_instance.sh_instance.id
  allocation_id       = aws_eip.sh-eip.id
  allow_reassociation = true
}

# Fetching Deployer
data "aws_instance" "dp_instance" {
  filter {
    name   = "tag:role"
    values = ["DP"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  filter {
    name   = "tag:stack_name"
    values = ["${var.project_name}"]
  }
  depends_on = [aws_autoscaling_group.dp-custom-autoscaling-group]
}

# Associating EIP to Deployer
resource "aws_eip_association" "dp_eip_association" {
  instance_id         = data.aws_instance.dp_instance.id
  allocation_id       = aws_eip.dp-eip.id
  allow_reassociation = true
}

# Fetching Indexers
data "aws_instances" "idx_instance" {
  filter {
    name   = "tag:role"
    values = ["idx"]
  }

  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available_zones.names[0], data.aws_availability_zones.available_zones.names[1], data.aws_availability_zones.available_zones.names[2]]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  filter {
    name   = "tag:stack_name"
    values = ["${var.project_name}"]
  }
  depends_on = [aws_autoscaling_group.idx-custom-autoscaling-group]
}

# Associating EIP to Indexers
resource "aws_eip_association" "idx_eip_association" {
  count               = var.idx_desired_capacity
  instance_id         = data.aws_instances.idx_instance.ids[count.index]
  allocation_id       = aws_eip.idx-eips[count.index].id
  allow_reassociation = true
}

# Fetching Forwarder
data "aws_instance" "hf_instance" {
  filter {
    name   = "tag:role"
    values = ["HF"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  filter {
    name   = "tag:stack_name"
    values = ["${var.project_name}"]
  }
  depends_on = [aws_autoscaling_group.hf-custom-autoscaling-group]
}

# Creating EBS volume for Search Head
resource "aws_ebs_volume" "sh-volume" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  size              = var.sh_volume_size
  type              = "gp2"
  tags = {
    Snapshot = "true"
    Name     = "${var.project_name}-SH Volume"
  }
}

# Creating EBS volume for Forwarder
resource "aws_ebs_volume" "hf-volume" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  size              = var.hf_volume_size
  type              = "gp2"
  tags = {
    Snapshot = "true"
    Name     = "${var.project_name}-HF Volume"
  }
}

# Creating EBS volume for Deployer
resource "aws_ebs_volume" "dp-volume" {
  availability_zone = data.aws_availability_zones.available_zones.names[2]
  size              = var.dp_volume_size
  type              = "gp2"
  tags = {
    Snapshot = "true"
    Name     = "${var.project_name}-DP Volume"
  }
}

# Creating volume for Indexers
resource "aws_ebs_volume" "idx-volume" {
  count             = var.idx_desired_capacity
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  size              = var.idx_volume_size
  type              = "gp2"
  tags = {
    Snapshot = "true"
    Name     = "${var.project_name}-Idx Volume"
  }
}

