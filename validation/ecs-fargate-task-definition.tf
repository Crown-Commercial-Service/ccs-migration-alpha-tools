module "ecs_fargate_task_definition" {
  source = "../resource-groups/ecs-fargate-task-definition"

  aws_account_id           = "123456789012"
  aws_region               = "eu-west-2"
  container_cpu            = 1048
  container_log_group_name = "log-group"
  container_memory         = 1048
  container_name           = "test"
  ecs_execution_role_arn   = "arn:aws::::::"
  family_name              = "family"
  image                    = "somerepo/image:latest"
}
