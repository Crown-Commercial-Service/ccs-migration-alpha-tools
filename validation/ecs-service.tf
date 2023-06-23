module "ecs_service" {
  source = "../modules/ecs-service"

  aws_account_id = "123456789012"
  aws_region     = "eu-west-1"
  container_cpu  = 512
  container_environment_variables = [
    { "name" : "environment", "value" : "dev" }
  ]
  container_memory       = 512
  desired_count          = 2
  ecs_cluster_arn        = "cluster-1234"
  ecs_execution_role_arn = "arn:aws:iam::123456789012:role/Project_Deployment"
  image                  = "docker-image:latest"
  lb_target_group_arn    = "arn:aws::::"
  resource_name_prefixes = {
    normal  = "PREFIX:123"
    hyphens = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  security_group_ids = [
    "sg-1234"
  ]
  service_name = "service"
  service_subnet_ids = [
    "subnet-1234"
  ]
  vpc_id = "vpc-1234"
}
