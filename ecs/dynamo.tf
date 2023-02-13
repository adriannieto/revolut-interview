resource "aws_dynamodb_table" "app" {
  name         = local.resource_name_prefix
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "name"
  table_class  = "STANDARD"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.key.arn
  }
  attribute {
    name = "name"
    type = "S"
  }
}