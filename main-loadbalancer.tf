resource "aws_lb" "my_lb" {
  name = "${var.name_prefix}-load-balancer"

  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.my_security_groups["public"].id]
  subnets         = [for subnet in aws_subnet.my_public_subnets : subnet.id]

  tags = {
    Name = "${var.name_prefix}-application-load-balancer"
  }
}

resource "aws_lb_target_group" "my_lb_target_group" {
  name   = "${var.name_prefix}-lb-target-group"
  vpc_id = aws_vpc.my_vpc.id

  port     = var.lb_target_port     # 8000
  protocol = var.lb_target_protocol # HTTP

  health_check {
    healthy_threshold   = var.lb_target_healthy_threshold   # 3
    unhealthy_threshold = var.lb_target_unhealthy_threshold # 3
    interval            = var.lb_target_interval            # 30
    timeout             = var.lb_target_timeout             # 10 
  }

  tags = {
    Name = "${var.name_prefix}-load-balancer-target-group"
  }
}


resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn

  port     = var.lb_listener_port
  protocol = var.lb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }

  tags = {
    Name = "${var.name_prefix}-load-balancer-listener"
  }
}