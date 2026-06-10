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
      data.aws_kms_key.primary.arn,
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
      data.aws_kms_key.primary.arn,
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

data "aws_kms_key" "primary" {
  key_id = "arn:aws:kms:${var.aws_region}:${var.backup_environment_id}:key/${var.backup_kms_key_id}"
}
