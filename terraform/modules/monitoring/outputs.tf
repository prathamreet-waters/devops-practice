output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ecs_high_cpu.arn
}
