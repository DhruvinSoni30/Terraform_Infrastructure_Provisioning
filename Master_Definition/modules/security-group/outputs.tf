# Master Node Security Group ID
output "master_security_group_id" {
  value = aws_security_group.master_security_group.id
}