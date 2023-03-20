locals {
  api_ecs_env_vars = [
    {
      name  = "APP_AWS_ACCOUNT_ID"
      value = var.aws_account_id
    },
    {
      name  = "POSTGRES_DB"
      value = "dbtobenamed"
    },
    {
      name  = "POSTGRES_SERVER"
      value = "tobenamed"
    },
    {
      name  = "POSTGRES_PORT"
      value = "5432"
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
