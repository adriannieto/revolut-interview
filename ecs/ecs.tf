resource "aws_ecs_cluster" "cluster" {
  name = local.resource_name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }


  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_service" "app" {
  name            = local.resource_name_prefix
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.app.arn
    container_name   = "app"
    container_port   = var.app_ecs_service_port
  }

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name = "app"

      image = var.app_ecs_task_container_image

      environment = [
        {
          name  = "PORT"
          value = tostring(var.app_ecs_service_port)
        }
      ]

      repositoryCredentials = {
         credentialsParameter = aws_secretsmanager_secret.docker_registry_secret.arn
      }

      portMappings = [
        {
          containerPort = var.app_ecs_service_port
          hostPort      = var.app_ecs_service_port
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-stream-prefix = "app"
        }
      }
    }

  ])
}