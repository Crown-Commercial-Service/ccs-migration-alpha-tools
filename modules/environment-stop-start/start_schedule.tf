resource "aws_scheduler_schedule" "mon_fri_start" {
  name = "environment-start-weekdays"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 8 ? * MON-FRI *)"

  state = "ENABLED"

  target {
    arn      = aws_lambda_function.start.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
  }
}
