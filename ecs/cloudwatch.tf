resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.resource_name_prefix
  kms_key_id        = aws_kms_key.key.key_id
  retention_in_days = 1

}