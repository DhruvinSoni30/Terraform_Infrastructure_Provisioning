# ALB DNS Name
output "application_load_balancer_dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}

# ALB ID
output "alb_id" {
  value = aws_lb.application_load_balancer.id
}

# ALB ARN
output "alb_arn" {
  value = aws_lb.application_load_balancer.arn
}

# Target Group ARN
output "target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}