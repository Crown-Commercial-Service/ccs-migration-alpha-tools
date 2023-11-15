# resource "aws_cloudwatch_event_rule" "weekdays_schedule" {
#   name = "rds_weekdays_schedule"
#   description = "Trigger start RDS instances on weekdays"
#   schedule_expression = "cron(0 8 ? * MON-FRI *)"
# }

# resource "aws_cloudwatch_event_target" "trigger_lambda_weekdays" {
#   rule = aws_cloudwatch_event_rule.weekdays_schedule.name
#   arn = aws_lambda_function.rds_start_function.arn
# }

# resource "aws_lambda_permission" "allow_weekdays_cloudwatch_rds_lambda" {
#   statement_id = "AllowExecutionFromCloudWatch"
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.rds_start_function.function_name
#   principal = "events.amazonaws.com"
#   source_arn = aws_cloudwatch_event_rule.weekdays_schedule.arn
# }

resource "aws_scheduler_schedule" "weekdays_schedule" {
  name = "weekdays-schedule"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 8 ? * MON-FRI *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn

    input = jsonencode({
      resources = [{
        type = "rds_db_instance"
        identifier = "api"
      },
      {
        type = "rds_db_instance"
        identifier = "frontend"
      },{
        type = "ecs_service"
        identifier = "api"
        desiredCount = 1
      },{
        type = "ecs_service"
        identifier = "frontend"
        desiredCount = 1
      },{
        type = "ecs_service"
        identifier = "admin"
        desiredCount = 1
      },{
        type = "ecs_service"
        identifier = "ingestion_worker"
        desiredCount = 1
      },{
        type = "ecs_service"
        identifier = "default_worker"
        desiredCount = 1
      }]
    })
  }
}
