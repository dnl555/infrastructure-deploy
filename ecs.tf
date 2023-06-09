resource "aws_cloudwatch_log_group" "api" {
  name              = "api"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "api-cluster" {
  name = "api-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.api.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "api" {
  cluster_name = aws_ecs_cluster.api-cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "api-task" {
  family = "api-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  task_role_arn      = aws_iam_role.api-taskexecution.arn
  execution_role_arn = aws_iam_role.api-taskexecution.arn

  memory = "512"
  cpu    = "256"

  container_definitions = jsonencode([
    {
      image = "${aws_ecr_repository.apirepo.repository_url}:api"
      name  = "api"

      portMappings = [
        {
          containerPort = 8181
          hostPort      = 8181
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs-api"
        }
      }

      environment = local.api_ecs_env_vars
      secrets     = local.api_ecs_secrets
    },
  ])
}

resource "aws_ecs_service" "api-service" {
  name                               = "api-service"
  cluster                            = aws_ecs_cluster.api-cluster.id
  task_definition                    = aws_ecs_task_definition.api-task.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 0
  enable_execute_command             = true

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.api-tg.arn
    container_name   = "api"
    container_port   = 8181
  }

  network_configuration {
    subnets          = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.api-sg.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}

resource "aws_security_group" "api-sg" {
  name   = "api"
  vpc_id = aws_vpc.main.id

  ingress = [
    {
      description      = "inbound container port from vpc"
      from_port        = 8181
      to_port          = 8181
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outbound any"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

# basic autoscaling CPU
resource "aws_appautoscaling_target" "dev_to_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.api-cluster.name}/${aws_ecs_service.api-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_cpu" {
  name               = "dev-to-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
