
resource "aws_secretsmanager_secret" "docker_registry_secret" {
  name_prefix = "/${local.resource_name_prefix}/registry/pwd"
  kms_key_id  = aws_kms_key.key.arn
}

resource "aws_secretsmanager_secret_version" "docker_registry_secret_version" {
  secret_id = aws_secretsmanager_secret.docker_registry_secret.id
  secret_string = jsonencode({
    username = var.app_ecs_container_registry_username
    password = var.app_ecs_container_registry_password
  })
}