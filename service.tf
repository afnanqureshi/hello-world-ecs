# ECS Service
resource "aws_ecs_service" "ecs-service" {
  name                    = "${var.app_name}-${var.app_environment}-service"
  cluster                 = aws_ecs_cluster.cluster.id
  task_definition         = "${aws_ecs_task_definition.ecs-task-definition.family}:${max(aws_ecs_task_definition.ecs-task-definition.revision, data.aws_ecs_task_definition.main.revision)}"
  desired_count           = 1
  enable_ecs_managed_tags = true
  depends_on              = [aws_lb_listener.ecs-alb-listener]
  launch_type             = "FARGATE"
  force_new_deployment    = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs-sg.id, aws_security_group.lb-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 8080
  }

  tags = {
    Name        = "${var.app_name}-service"
    Environment = var.app_environment
  }
}