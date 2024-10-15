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
      "arn:aws:s3:::ccs-digitalmarketplace-postgres-etl-extract-${var.environment_name}",
      "arn:aws:s3:::ccs-digitalmarketplace-postgres-etl-extract-${var.environment_name}/*"
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
      "ecr:DescribeImages", # Possibly not needed
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages", # Possibly not needed
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

resource "aws_iam_role" "rds_to_s3_sfn" {
  name = "${var.migrator_name}_rds_to_s3_sfn"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Sid = "AllowStatesAssumeRole"

        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "rds_to_s3_sfn" {
  version = "2012-10-17"

  statement {
    sid = "AllowPassEcsExecRole"

    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      var.ecs_extract_execution_role_arn,
    ]
  }

  statement {
    sid = "AllowRunPGETLTasks"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "${module.extract_task.task_definition_arn_without_revision}:*"
    ]
  }

  statement {
    sid = "AllowStopPGETLTasks"

    effect = "Allow"

    actions = [
      "ecs:DescribeTasks",
      "ecs:StopTask"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowDotSyncExecutionOfEcsTasks"

    effect = "Allow"

    actions = [
      "events:DescribeRule",
      "events:PutRule",
      "events:PutTargets"
    ]

    resources = [
      "arn:aws:events:${var.aws_region}:${var.aws_account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
    ]
  }
}

resource "aws_iam_role_policy" "rds_to_s3_sfn" {
  role   = aws_iam_role.rds_to_s3_sfn.name
  policy = data.aws_iam_policy_document.rds_to_s3_sfn.json
}

resource "aws_iam_role_policy" "etl_policy" {
  role   = aws_iam_role.rds_to_s3_sfn.name
  policy = data.aws_iam_policy_document.etl_policy.json
}
