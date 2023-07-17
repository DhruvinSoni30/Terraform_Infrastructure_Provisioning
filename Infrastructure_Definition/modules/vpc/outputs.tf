# VPC ID
output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

# Default Subnte ids
output "default_subnet_ids" {
  value = data.aws_subnet.subnet_id.*.id
}
