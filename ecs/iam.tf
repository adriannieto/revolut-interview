resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.resource_name_prefix}-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Logs 
# Ignore wildcard in this scenario, its safe
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "cloudwatch_push_logs" {

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.ecs.arn}:*"]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "cloudwatch_push_logs" {
  name   = "${local.resource_name_prefix}-cloudwatch-push-logs"
  policy = data.aws_iam_policy_document.cloudwatch_push_logs.json
}

resource "aws_iam_role_policy_attachment" "task_execution_cloudwatch_push_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_push_logs.arn
}

# SSM 
data "aws_iam_policy_document" "secrets_manager_registry_creds" {

  statement {
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]

    resources = [ 
      aws_secretsmanager_secret.docker_registry_secret.arn, 
      aws_kms_key.key.key_id
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "secrets_manager_registry_creds" {
  name   = "${local.resource_name_prefix}-ssm-registry-creds"
  policy = data.aws_iam_policy_document.secrets_manager_registry_creds.json
}

resource "aws_iam_role_policy_attachment" "task_execution_secrets_manager_registry_creds" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_manager_registry_creds.arn
}

# DynamoDB
data "aws_iam_policy_document" "dynamodb_read_table_policy" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:ListTables",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]

    resources = [aws_dynamodb_table.app.arn]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "dynamodb_read_table_policy" {
  name   = "${local.resource_name_prefix}-dynamodb-read"
  policy = data.aws_iam_policy_document.dynamodb_read_table_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_dynamodb_read_table" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.dynamodb_read_table_policy.arn
}

data "aws_iam_policy_document" "dynamodb_write_table_policy" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:ListTables",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
    ]

    resources = [aws_dynamodb_table.app.arn]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "dynamodb_write_table_policy" {
  name   = "${local.resource_name_prefix}-dynamodb-write"
  policy = data.aws_iam_policy_document.dynamodb_write_table_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_dynamodb_write_table" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.dynamodb_write_table_policy.arn
}


resource "aws_iam_role" "ecs_task_role" {
  name = "${local.resource_name_prefix}-ecs-task-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}