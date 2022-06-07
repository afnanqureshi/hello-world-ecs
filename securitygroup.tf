# ECS Security Group
resource "aws_security_group" "ecs-sg" {
  name   = "${var.app_name}-ecs-sg"
  vpc_id = aws_vpc.ecs-vpc.id
  ingress {
    description     = "Load Balancer to ECS"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    description      = "All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-ecs-sg"
    Environment = var.app_environment
  }
}

# Load Balancer Security Group
resource "aws_security_group" "lb-sg" {
  name   = "${var.app_name}-lb-sg"
  vpc_id = aws_vpc.ecs-vpc.id
  ingress {
    description      = "All Traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-lb-sg"
    Environment = var.app_environment
  }
}