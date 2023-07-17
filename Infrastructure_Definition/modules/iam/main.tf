# Creating IAM Admin Policy
resource "aws_iam_policy" "admin_policy" {
  name        = "AdminPolicy"
  description = "Administrative access for all services"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Creating IAM Admin Role
resource "aws_iam_role" "admin_role" {
  name               = "admin-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy attachment 
resource "aws_iam_role_policy_attachment" "admin_attachment" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

# Attach role to instance profile 
resource "aws_iam_instance_profile" "admin_instance_profile" {
  name = "admin-instance-profile"
  role = aws_iam_role.admin_role.name
}