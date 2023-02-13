resource "aws_kms_key" "key" {
  description             = "alias/${local.resource_name_prefix}-app"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy = <<JSON
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${var.region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
                }
            }
        }
    ]
}
JSON
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.resource_name_prefix}-app"
  target_key_id = aws_kms_key.key.key_id
}