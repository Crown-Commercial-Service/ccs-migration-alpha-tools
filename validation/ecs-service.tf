module "ecs_service" {
  source = "../modules/ecs-service"

  aws_account_id = "123456789012"
  aws_region     = "eu-west-1"
  container_definitions = {
    svc = {
      cpu = 512
      environment_variables = [
        { "name" : "environment", "value" : "dev" }
      ]
      essential                    = true
      healthcheck_command          = "curl localhost"
      image                        = "docker-image:latest"
      memory                       = 512
      mounts                       = []
      override_command             = null
      port                         = 1234
      secret_environment_variables = []
    }
  }
  desired_count          = 2
  ecs_cluster_arn        = "cluster-1234"
  ecs_execution_role_arn = "arn:aws:iam::123456789012:role/Project_Deployment"
  lb_target_group_arn    = "arn:aws::::"
  resource_name_prefixes = {
    normal        = "PREFIX:123"
    hyphens       = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  security_group_ids = [
    "sg-1234"
  ]
  service_name = "service"
  service_subnet_ids = [
    "subnet-1234"
  ]
  vpc_id      = "vpc-1234"
  task_cpu    = 512
  task_memory = 512
}
