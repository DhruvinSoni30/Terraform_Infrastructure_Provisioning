# IAM Instance Profile 
output "instance_profile" {
  value = aws_iam_instance_profile.admin_instance_profile.name
}
