resource "aws_secretsmanager_secret" "api-secrets" {
  name = "api-secrets"
}

locals {
  secrets = {
    "api_token"   = var.api_token
    "db_password" = var.db_password
  }
}

resource "aws_secretsmanager_secret_version" "api-secrets-values" {
  secret_id     = aws_secretsmanager_secret.api-secrets.id
  secret_string = jsonencode(local.secrets)
}
