module "ecr_repository_group" {
  source = "../resource-groups/ecr-repository-group"

  is_ephemeral = true
  repository_names = [
    "api",
    "web",
  ]
}
