output "app_url" {
  value = "http://${aws_alb.ecs.dns_name}/"
}


output "app_ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "app_ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "app_ecs_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.ecs.name
}