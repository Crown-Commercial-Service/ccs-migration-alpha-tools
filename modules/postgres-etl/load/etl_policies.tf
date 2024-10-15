data "aws_iam_policy_document" "bucket_access" {
  version = "2012-10-17"

  statement {
    sid = "AllowBucketActions"

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]

    resources = [
      "arn:aws:s3:::ccs-digitalmarketplace-postgres-etl-load-${var.environment_name}",
      "arn:aws:s3:::ccs-digitalmarketplace-postgres-etl-load-${var.environment_name}/*"
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
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/postgres-etl", # Dev
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/postgres-etl:*", # Dev
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/postgres-etl", # SBX
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/postgres-etl:*", # SBX
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/postgres-etl",  # Prod
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/postgres-etl:*"  # Prod
    ]
  }
}

resource "aws_iam_role" "k8s_postgres_etl" {
  name               = "k8s-postgres-etl"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::665505400356:role/eks-paas-mountpoint-s3-csi-driver"
        },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "k8s_trigger_sfn" {
  name        = "k8s-trigger-sfn"
  description = "Allows the k8s-postgres-etl role to trigger the Postgres ETL Step Function"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "states:StartExecution",
        Resource  = "arn:aws:states:eu-west-2:259593444005:stateMachine:postgres-etl-s3-to-rds"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k8s_etl_trigger_sfn" {
  role       = aws_iam_role.k8s_postgres_etl.name
  policy_arn = aws_iam_policy.k8s_trigger_sfn.arn
}

data "aws_iam_policy_document" "logging_policy" {
  version = "2012-10-17"
  # We are expecting repeated Sids of "DescribeAllLogGroups", hence `overwrite` rather than `source`
  override_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    module.load_task.write_task_logs_policy_document_json
  ]
}

resource "aws_iam_role_policy" "logging" {
  role   = var.ecs_load_execution_role.name
  policy = data.aws_iam_policy_document.logging_policy.json
}
