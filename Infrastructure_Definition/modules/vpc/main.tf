# Using data source fetching the availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Using data block fetching the default VPC from AWS
data "aws_vpc" "default" {
  default = true
}

# Using data block fetching the default subnets from AWS
data "aws_subnets" "default" {
}

data "aws_subnet" "subnet_id" {
  count = length(data.aws_availability_zones.available.names)
  id    = tolist(data.aws_subnets.default.ids)[count.index]
}