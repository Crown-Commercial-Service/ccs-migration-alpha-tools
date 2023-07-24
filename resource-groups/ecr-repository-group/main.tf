resource "aws_ecr_repository" "repo" {
  for_each             = toset(var.repository_names)
  name                 = each.value
  force_delete         = var.is_ephemeral
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "expire_untagged" {
  for_each   = aws_ecr_repository.repo
  repository = each.value.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than ${var.expire_untagged_images_older_than_days} days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${var.expire_untagged_images_older_than_days}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

locals {
  repo_arns = [for repo in aws_ecr_repository.repo : repo.arn]
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

    resources = local.repo_arns
  }
}
