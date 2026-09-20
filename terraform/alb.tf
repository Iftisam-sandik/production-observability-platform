resource "aws_lb" "application" {
  name               = "observability-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name = "observability-alb"
  }
}

resource "aws_lb_target_group" "application" {
  name     = "observability-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  deregistration_delay = 15

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "observability-app-tg"
  }
}

resource "aws_lb_target_group_attachment" "app_1" {
  target_group_arn = aws_lb_target_group.application.arn
  target_id        = aws_instance.app_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_2" {
  target_group_arn = aws_lb_target_group.application.arn
  target_id        = aws_instance.app_2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}
