data "aws_iam_policy_document" "s3" {
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
      "arn:aws:s3:::ccs-digitalmarketplace-${var.migrator_name}-extract-${var.environment_name}",
      "arn:aws:s3:::ccs-digitalmarketplace-${var.migrator_name}-extract-${var.environment_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "ecr" {
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
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/${var.migrator_name}",   # Dev
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/${var.migrator_name}:*", # Dev
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/${var.migrator_name}",   # SBX
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/${var.migrator_name}:*", # SBX
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/${var.migrator_name}",   # Prod
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/${var.migrator_name}:*"  # Prod
    ]
  }
}

data "aws_iam_policy_document" "ecs_exec" {
  version = "2012-10-17"

  statement {
    sid = "AllowECSExec"

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

data "aws_iam_policy_document" "read_creds_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowReadCredsSecrets"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      var.db_connection_url_ssm_param_arn
    ]
  }
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
      var.ecs_extract_execution_role.arn,
      module.extract_task.task_role_arn
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

  statement {
    sid = "AllowAuthorizationToken"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "logging" {
  version = "2012-10-17"
  # We are expecting repeated Sids of "DescribeAllLogGroups", hence `overwrite` rather than `source`
  override_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    module.extract_task.write_task_logs_policy_document_json
  ]
}

# Permissions which need to be granted to the main project's ECS Execution role
#
data "aws_iam_policy_document" "postgres_etl" {
  version = "2012-10-17"
  # We are expecting repeated Sids of "DescribeAllLogGroups", hence `overwrite` rather than `source`
  override_policy_documents = [
    # Main ECS execution role needs access to decrypt and inject SSM params as env vars
    data.aws_iam_policy_document.read_creds_ssm.json,
    module.extract_task.write_task_logs_policy_document_json,
  ]
}

resource "aws_iam_role" "rds_to_s3_sfn" {
  name = "${var.migrator_name}-rds-to-s3-sfn"

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

resource "aws_iam_role_policy" "ecr" {
  name   = "${var.migrator_name}-extract-ecr"
  role   = var.ecs_extract_execution_role.name
  policy = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy" "ecs_execution_role__postgres_etl_extract" {
  name   = "${var.migrator_name}-extract"
  role   = module.extract_task.task_role_name
  policy = data.aws_iam_policy_document.postgres_etl.json
}

resource "aws_iam_role_policy" "ecs_exec__postgres_etl_extract" {
  name   = "${var.migrator_name}-extract-ecs-exec"
  role   = module.extract_task.task_role_name
  policy = data.aws_iam_policy_document.ecs_exec.json
}

resource "aws_iam_role_policy" "logging" {
  name   = "${var.migrator_name}-extract-logging"
  role   = var.ecs_extract_execution_role.name
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role_policy" "rds_to_s3_sfn" {
  name   = "${var.migrator_name}-rds-to-s3-sfn"
  role   = aws_iam_role.rds_to_s3_sfn.name
  policy = data.aws_iam_policy_document.rds_to_s3_sfn.json
}

resource "aws_iam_role_policy" "s3__postgres_etl_extract" {
  name   = "${var.migrator_name}-extract-s3"
  role   = module.extract_task.task_role_name
  policy = data.aws_iam_policy_document.s3.json
}
