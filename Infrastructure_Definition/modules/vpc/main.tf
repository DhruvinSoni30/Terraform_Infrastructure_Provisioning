# Using data block fetching the default VPC from AWS
data "aws_vpc" "default" {
  default = true
}

# Using data block fetching the default subnets from AWS
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Using data block fetching the default internet gateway from AWS
data "aws_internet_gateway" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Using data block fetching the default route table from AWS
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Using data block fetching the default NACL from AWS
data "aws_network_acl" "default" {
  vpc_id = data.aws_vpc.default.id
}
