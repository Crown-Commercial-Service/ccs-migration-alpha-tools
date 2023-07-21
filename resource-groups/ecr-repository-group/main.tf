resource "aws_ecr_repository" "repo" {
  for_each             = toset(var.repository_names)
  name                 = each.value
  force_delete         = var.is_ephemeral
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_iam_policy_document" "pull_repo_images" {
  version = "2012-10-17"

  statement {
    sid = "AllowGetAuthorizationToken"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowLayerAndImageAccess"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [for repo in aws_ecr_repository.repo : repo.arn]
  }
}
