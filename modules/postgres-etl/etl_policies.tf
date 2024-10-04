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
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/postgres-etl:*", # Dev
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/postgres-etl:*", # SBX
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/postgres-etl:*"  # Prod
    ]
  }
}

resource "aws_iam_policy" "bucket_access" {
  name = "bucket_access"
  description = "Allows access to the bucket"
  policy = data.aws_iam_policy_document.bucket_access.json
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "allow-ecs-exec-policy"
  description = "Enables ECS Execute Command"
  policy      = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_policy" "etl_policy" {
  name        = "etl_policy"
  description = "Allows access to ECR and S3"
  policy      = data.aws_iam_policy_document.etl_policy.json
}
