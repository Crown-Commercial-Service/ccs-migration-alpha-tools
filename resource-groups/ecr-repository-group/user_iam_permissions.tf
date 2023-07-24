# Helper group to enable operatives to run this migrator
resource "aws_iam_group" "allow_ecr_login_and_push" {
  name = "allow-ecr-login-and-push"
}

data "aws_iam_policy_document" "allow_ecr_login_and_push" {
  version = "2012-10-17"

  statement {
    sid = "AllowGetAuthorizationToken"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowDescribeRegistry"

    effect = "Allow"

    actions = [
      "ecr:DescribeRegistry",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowDescribeRepositories"

    effect = "Allow"

    actions = [
      "ecr:DescribeRepositories"
    ]

    resources = local.repo_arns
  }

  statement {
    sid = "AllowImagePush"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = local.repo_arns
  }
}

# Creating a managed policy since this it's conceivable this could be used by other user groups / roles
resource "aws_iam_policy" "allow_ecr_login_and_push" {
  name   = "allow-ecr-login-and-push"
  policy = data.aws_iam_policy_document.allow_ecr_login_and_push.json
}

resource "aws_iam_group_policy_attachment" "allow_ecr_login_and_push__allow_ecr_login_and_push" {
  group      = aws_iam_group.allow_ecr_login_and_push.name
  policy_arn = aws_iam_policy.allow_ecr_login_and_push.arn
}
