locals {
  resource_name_prefix = "${var.environment}-${var.project}-${var.app_name}"
}

data "aws_caller_identity" "current" {}
