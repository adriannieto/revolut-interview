resource "aws_kms_key" "key" {
  description             = "alias/${local.resource_name_prefix}-app"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.resource_name_prefix}-app"
  target_key_id = aws_kms_key.key.key_id
}