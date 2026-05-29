data "archive_file" "backup_copy_to_vault" {
  output_path = "${path.root}/files/backup-copy-to-vault.zip"
  source_file = "${path.module}/backup_copy_lambda.py"
  type        = "zip"
}

data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "backup_kms_access" {
  statement {
    sid    = "AllowUseOfSharedKMSKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:${local.primary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}",
      "arn:aws:kms:${local.secondary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}"
    ]
  }

  statement {
    sid    = "AllowGrantsForSharedKMSKey"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = [
      "arn:aws:kms:${local.primary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}",
      "arn:aws:kms:${local.secondary_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}"
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "backup_vault_policy" {
  statement {
    sid    = "Allow ${var.backup_environment_id} to copy into local-vault"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.backup_environment_id}:root"]
    }

    actions = ["backup:CopyIntoBackupVault"]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eventbridge_forwarder_policy" {
  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = ["arn:aws:events:eu-west-2:${var.backup_environment_id}:event-bus/default"]
  }
}

data "aws_iam_policy_document" "lambda_logging_permissions" {
  statement {
    sid    = "AllowLambdaToWriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda_backup[0].arn}:*"
    ]
  }
}
