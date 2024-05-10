resource "aws_scheduler_schedule" "mon_fri_start" {
  name = "environment-start-weekdays"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 8 ? * MON-FRI *)"

  state = var.start_schedule_enabled ? "ENABLED" : "DISABLED"

  target {
    arn      = aws_lambda_function.start.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
  }
}
