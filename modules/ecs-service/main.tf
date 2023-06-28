resource "aws_ecs_service" "service" {
  name                 = var.service_name
  cluster              = var.ecs_cluster_arn
  desired_count        = var.desired_count
  force_new_deployment = false
  launch_type          = "FARGATE"
  dynamic "load_balancer" {
    for_each = toset(var.lb_target_group_arn == null ? [] : ["ok"])
    content {
      container_name   = var.service_container_name
      container_port   = tostring(var.service_port)
      target_group_arn = var.lb_target_group_arn
    }
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

  aws_account_id         = var.aws_account_id
  aws_region             = var.aws_region
  container_definitions  = var.container_definitions
  ecs_execution_role_arn = var.ecs_execution_role_arn
  family_name            = var.service_name
  task_cpu               = var.task_cpu
  task_log_group_name    = module.task_log_group.log_group_name
  task_memory            = var.task_memory
}
