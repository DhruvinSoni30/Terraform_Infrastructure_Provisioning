# VPC ID
output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

# Default Subnte ids
output "default_subnet_ids" {
  value = data.aws_subnet_ids.default.ids
}

# Default internet gateway
output "default_internet_gateway_id" {
  value = data.aws_internet_gateway.default.id
}

# Default route table
output "default_route_table_id" {
  value = data.aws_route_table.default.id
}

# Default NCAL
output "default_network_acl_id" {
  value = data.aws_network_acl.default.id
}