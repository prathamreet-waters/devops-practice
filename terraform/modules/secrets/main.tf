resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.environment}/app/config"
  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "app_secrets_val" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DB_PASSWORD  = var.db_password
    API_KEY      = "default-dev-api-key"
    SECRET_TOKEN = "super-secret-token"
  })
}
