# Indexers Security Group ID
output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

# Search Head Security Group ID
output "sh_security_group_id" {
  value = aws_security_group.sh_security_group.id
}

# Forwarder Security Group ID
output "hf_security_group_id" {
  value = aws_security_group.hf_security_group.id
}

# Deployer Security Group ID
output "dp_security_group_id" {
  value = aws_security_group.dp_security_group.id
}

# Master Node Security Group ID
output "master_security_group_id" {
  value = aws_security_group.master_security_group.id
}