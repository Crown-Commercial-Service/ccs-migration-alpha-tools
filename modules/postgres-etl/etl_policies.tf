data "aws_iam_policy_document" "bucket_access" {
  version = "2012-10-17"

  statement {
    sid = "AllowBucketActions"

    effect = "Allow"

    actions = [
      "s3:PutObjectVersionAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging",
      "s3:GetObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::ccs-digitalmarketplace-postgres-etl-extract-pre-prod"
    ]
  }
}

data "aws_iam_policy_document" "ecs_exec_policy" {
  version = "2012-10-17"

  statement {
    sid = "AllowECSExecPolicy"

    effect = "Allow"

    actions = [
      "ssmmessages:OpenDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:CreateControlChannel"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "etl_policy" {
  version = "2012-10-17"

  statement {
    sid = "AllowAuthorizationToken"

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
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/postgres-etl:*", # Dev
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/postgres-etl:*", # SBX
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/postgres-etl:*"  # Prod
    ]
  }
}
