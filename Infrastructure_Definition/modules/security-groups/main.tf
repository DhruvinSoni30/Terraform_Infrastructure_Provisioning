# Creating Security Group for the Indexers
resource "aws_security_group" "alb_security_group" {
  name   = "alb security group"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "UI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Management port"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Replication port"
    from_port   = 9887
    to_port     = 9887
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HEC access"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = var.hec_access
  }

  ingress {
    description = "Ingestion port"
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = var.ingest_access
  }

  ingress {
    description = "Puppet port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-security-group"
    Env  = var.env
    Type = var.type
  }
}

# Creating Security Group for the Search Head 
resource "aws_security_group" "sh_security_group" {
  name   = "SH security group"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.hec_access
  }

  ingress {
    description = "UI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Management port"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Puppet port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-SH-security-group"
    Env  = var.env
    Type = var.type
  }
}

# Creating Security Group for the Forwarder
resource "aws_security_group" "hf_security_group" {
  name   = "HF security group"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "UI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Puppet port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Management port"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Custom ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-HF-security-group"
    Env  = var.env
    Type = var.type
  }
}

# Creating Security Group for the Deployer 
resource "aws_security_group" "dp_security_group" {
  name   = "DP security group"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "UI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.ui_access
  }

  ingress {
    description = "Management port"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Puppet port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Deployer-security-group"
    Env  = var.env
    Type = var.type
  }
}

# Creating Security Group for the Master Node
resource "aws_security_group" "master_security_group" {
  name   = "Master security group"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "Puppet port"
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Master-security-group"
    Env  = var.env
    Type = var.type
  }
}
