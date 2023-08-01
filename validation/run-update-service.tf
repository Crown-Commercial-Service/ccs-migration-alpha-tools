module "run_update_service" {
  source = "../modules/run-update-service"

  ecs_cluster_arn = "arn:aws:ecs:eu-west-2:123456789012:cluster/MAINAPP"
}
