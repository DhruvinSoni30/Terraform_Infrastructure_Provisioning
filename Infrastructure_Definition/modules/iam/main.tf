# Using data block fetching the IAM role
data "aws_iam_role" "admin_role" {
  name = "admin-role"  
}

# Attach role to instance profile 
resource "aws_iam_instance_profile" "admin_instance_profile" {
  name = "admin-instance-profile"
  role = data.aws_iam_role.admin_role.id
}
