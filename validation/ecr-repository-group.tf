module "ecr_repository_group" {
  source = "../resource-groups/ecr-repository-group"

  expire_untagged_images_older_than_days = 7
  is_ephemeral                           = true
  repository_names = [
    "api",
    "web",
  ]
}
