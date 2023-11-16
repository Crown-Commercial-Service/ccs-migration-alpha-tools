resource "aws_scheduler_schedule" "weekends_schedule" {
  name = "weekends-schedule"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 18 ? * FRI-SUN *)"

  target {
    arn      = "arn:aws:lambda:eu-west-2:938662338283:function:RDSStopFunction"
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn

    input = jsonencode({
      resources = [{
        type       = "rds_db_instance"
        identifier = "api"
        },
        {
          type       = "rds_db_instance"
          identifier = "frontend"
          }, {
          type         = "ecs_service"
          identifier   = "api"
          desiredCount = 1
          }, {
          type         = "ecs_service"
          identifier   = "frontend"
          desiredCount = 1
          }, {
          type         = "ecs_service"
          identifier   = "admin"
          desiredCount = 1
          }, {
          type         = "ecs_service"
          identifier   = "ingestion_worker"
          desiredCount = 1
          }, {
          type         = "ecs_service"
          identifier   = "default_worker"
          desiredCount = 1
      }]
    })
  }
}
