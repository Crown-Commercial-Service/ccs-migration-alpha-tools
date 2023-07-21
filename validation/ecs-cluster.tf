module "ecs_cluster" {
  source = "../modules/ecs-cluster"

  cluster_name = "cluster1"
  execution_role = {
    arn  = "arn:1234567",
    name = "exec-role"
  }
  execution_role_policy_docs = {}
}
