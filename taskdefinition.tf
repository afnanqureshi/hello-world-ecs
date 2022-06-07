# ECS Task Definition
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "${var.app_name}-task"
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-${var.app_environment}-container"
      image     = "YOUR_ECR_IMAGE_URL:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log-group.id
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "${var.app_name}-${var.app_environment}"
        }
      }
    }
  ])
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.ecs-task-definition.family
}
