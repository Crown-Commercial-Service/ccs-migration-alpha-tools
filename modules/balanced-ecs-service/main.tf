resource "aws_ecs_service" "service" {
  name                 = var.service_name
  cluster              = var.ecs_cluster_arn
  desired_count        = var.desired_count
  force_new_deployment = false
  launch_type          = "FARGATE"
  load_balancer {
    container_name   = var.service_name
    container_port   = tostring(var.container_port)
    target_group_arn = var.lb_target_group_arn
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = var.security_group_ids
    subnets          = var.service_subnet_ids
  }
  task_definition = module.service_task_definition.task_definition_arn
}

module "service_task_definition" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id                  = var.aws_account_id
  aws_region                      = var.aws_region
  container_cpu                   = var.container_cpu
  container_environment_variables = var.container_environment_variables
  container_healthcheck_command   = var.container_healthcheck_command
  container_log_group_name        = module.container_log_group.log_group_name
  container_memory                = var.container_memory
  container_name                  = var.service_name
  container_port                  = var.container_port
  ecs_execution_role_arn          = var.ecs_execution_role_arn
  family_name                     = var.service_name
  image                           = var.image
  secret_environment_variables    = var.secret_environment_variables
}
