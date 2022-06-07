# Load Balancer
resource "aws_lb" "ecs-alb" {
  name               = "${var.app_name}-${var.app_environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = aws_subnet.public.*.id
  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

# Target Group for the Load Balancer
resource "aws_lb_target_group" "ecs-alb-tg" {
  name        = "${var.app_name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs-vpc.id
  target_type = "ip"
  tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }
}

# Listeners for the load balancer
resource "aws_lb_listener" "ecs-alb-listener" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
  }
}