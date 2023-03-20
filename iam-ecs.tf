resource "aws_iam_role" "api-taskexecution" {
  name = "api-ecs-taskExecution"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "api-ecs-taskExecution-inlinepolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
          ]
          Effect = "Allow"
          Resource = [
            "*"
          ]
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
          ]
          Effect = "Allow"
          Resource = [
            "*"
          ]
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
          ]
          Effect = "Allow"
          Resource = [
            aws_secretsmanager_secret.api-secrets.arn,
          ]
        },
      ]
    })
  }
}

resource "aws_iam_service_linked_role" "iam-api-ecs-autoscaling-service-role" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}
