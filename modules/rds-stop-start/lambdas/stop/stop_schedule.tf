# resource "aws_cloudwatch_event_rule" "weekends_schedule" {
#   name = "rds_weekends_schedule"
#   description = "Trigger stop RDS instances on weekends"
#   schedule_expression = "cron(0 18 ? * SAT-SUN *)"
# }

# resource "aws_cloudwatch_event_target" "trigger_lambda_weekends" {
#   rule = aws_cloudwatch_event_rule.weekends_schedule.name
#   arn = aws_lambda_function.rds_stop_function.arn
# }

# resource "aws_lambda_permission" "allow_weekends_cloudwatch_rds_lambda" {
#   statement_id = "AllowExecutionFromCloudWatch"
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.rds_stop_function.function_name
#   principal = "events.amazonaws.com"
#   source_arn = aws_cloudwatch_event_rule.weekends_schedule.arn
# }

resource "aws_scheduler_schedule" "weekends_schedule" {
  name = "weekends-schedule"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 18 ? * FRI-SUN *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.lambda_stop_role.arn

    input = jsonencode({
      resources = [{
        type       = "rds_db_instance"
        identifier = "api"
        },
        {
          type       = "rds_db_instance"
          identifier = "frontend"
          }, {
          type       = "ecs_service"
          identifier = "api"
          }, {
          type       = "ecs_service"
          identifier = "frontend"
          }, {
          type       = "ecs_service"
          identifier = "admin"
      }]
    })
  }
}
