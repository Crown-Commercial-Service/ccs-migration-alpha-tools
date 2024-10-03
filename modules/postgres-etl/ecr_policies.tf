data "aws_iam_policy_document" "pull_all_repo_images" {
  version = "2012-10-17"

  statement {

    sid = "AllowAssumeCICDRolesGPaaSMigration"

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:AssumeRoleWithSAML",
      "sts:AssumeRoleWithWebIdentity"
    ]

    resources = [
      "*"
    ]
  }

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

    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/*"
    ]
  }
}
