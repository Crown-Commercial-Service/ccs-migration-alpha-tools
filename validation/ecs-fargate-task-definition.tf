module "ecs_fargate_task_definition" {
  source = "../resource-groups/ecs-fargate-task-definition"

  aws_account_id = "123456789012"
  aws_region     = "eu-west-2"
  container_definitions = {
    service = {
      cpu = 1024
      environment_variables = [
        { "name" : "environment", "value" : "dev" }
      ]
      essential           = true
      healthcheck_command = "curl localhost"
      image               = "somerepo/image:latest"
      memory              = 1024
      mounts = [
        {
          mount_point = "/mnt/thing"
          read_only   = false
          volume_name = "efs0"
        }
      ]
      override_command = ["server", "run"]
      port             = 1234
      secret_environment_variables = [
        { "name" : "PASSWORD", "valueFrom" : "arn:ssm::::" },
      ]
    }
  }
  ecs_execution_role_arn = "arn:aws:iam::123456789012:role/Project_Deployment"
  family_name            = "family"
  task_cpu               = 1024
  task_memory            = 1024
  volumes = [
    {
      access_point_id = "fsap-06a1234ec01af7fe9"
      file_system_id  = "fs-00b12384470573e549"
      volume_name     = "share01"
    }
  ]
}
