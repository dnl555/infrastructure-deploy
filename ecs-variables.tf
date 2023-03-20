locals {
  api_ecs_env_vars = [
    {
      name  = "APP_AWS_ACCOUNT_ID"
      value = var.aws_account_id
    },
    {
      name  = "POSTGRES_DB"
      value = aws_db_instance.default.db_name
    },
    {
      name  = "POSTGRES_SERVER"
      value = aws_db_instance.default.address
    },
    {
      name  = "POSTGRES_PORT"
      value = tostring(aws_db_instance.default.port)
    },
    {
      name  = "POSTGRES_USER"
      value = var.db_username
    },
  ]

  api_ecs_secrets = [
    {
      valueFrom = "${aws_secretsmanager_secret.api-secrets.arn}:api_token::"
      name      = "API_AUTH_TOKEN"
    },
    {
      valueFrom = "${aws_secretsmanager_secret.api-secrets.arn}:db_password::"
      name      = "POSTGRES_PASSWORD"
    }
  ]
}
