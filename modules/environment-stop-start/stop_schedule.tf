resource "aws_scheduler_schedule" "mon_fri_stop" {
  name = "environment-stop-weekdays"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 18 ? * MON-FRI *)"

  target {
    arn      = aws_lambda_function.stop.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn

    input = jsonencode(local_file.resources)
  }
}
