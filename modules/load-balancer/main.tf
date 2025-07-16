resource "aws_lb" "main" {
  name               = var.name
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }
  
  tags = {
    Name = "${var.name}-target-group"
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count = length(var.target_instances)
  
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_instances[count.index]
  port             = 80
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}