# HCL representation of the JSON

locals {
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
}

resource "local_file" "resources" {
  content  = jsonencode(local.resources)
  filename = "${path.module}/lambdas/resources.json"
}
