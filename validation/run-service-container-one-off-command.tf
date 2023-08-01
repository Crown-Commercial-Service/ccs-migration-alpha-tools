resource "aws_ecs_service" "api" {
  name = "api"
}

module "run_uploader_web_service_command" {
  source = "../modules/run-service-container-one-off-command"

  ecs_execution_role_arn = "arn:aws:ecs:eu-west-2:123456789012:role/ECS"
  service                = aws_ecs_service.api
}
