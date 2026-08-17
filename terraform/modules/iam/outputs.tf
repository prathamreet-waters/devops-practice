output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "github_oidc_role_arn" {
  value = length(aws_iam_role.github_oidc) > 0 ? aws_iam_role.github_oidc[0].arn : ""
}
