# Create Application Load Balancer
resource "aws_lb" "application_load_balancer" {

  name                       = "${var.project_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [var.public_subnet_az1_id, var.public_subnet_az2_id, var.public_subnet_az3_id]
  security_groups            = [var.alb_security_group]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
    Env  = var.env
    Type = var.type
  }
}

# Create Listener that will listen on port 8000
resource "aws_lb_listener" "application_load_balancer_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = {
    Name = "${var.project_name}-alb-listener"
    Env  = var.env
    Type = var.type
  }
}

# Create Target Group
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project_name}-tg-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
  }

  tags = {
    Name = "${var.project_name}-alb-target-group"
    Env  = var.env
    Type = var.type
  }
}