resource "aws_iam_user" "ithc_audit" {
  name = "${var.resource_name_prefixes.hyphens_lower}-ithc-audit"
}

resource "aws_iam_group" "ithc_audit" {
  name = "${var.resource_name_prefixes.hyphens_lower}-ithc-audit"
}

resource "aws_iam_user_group_membership" "ithc_audit" {
  groups = [
    aws_iam_group.ithc_audit.name
  ]
  user   = aws_iam_user.ithc_audit.name
}

resource "aws_iam_group_policy_attachment" "ithc_audit__read_only_access" {
  group = aws_iam_group.ithc_audit.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "ithc_audit__security_audit" {
  group = aws_iam_group.ithc_audit.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

data "aws_iam_policy_document" "custom_ithc_access_rules" {
  statement {
    sid    = "AllowAccessKeyManagement"
    effect = "Allow"
    actions = [
      "iam:DeleteAccessKey",
      "iam:UpdateAccessKey",
      "iam:CreateAccessKey",
      "iam:ListAccessKeys"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:DeleteVirtualMFADevice",
      "iam:CreateVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnUserMFA"
    effect = "Allow"
    actions = [
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:EnableMFADevice",
      "iam:DeactivateMFADevice",
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "BlockMostAccessUnlessSignedInWithMFA"
    effect = "Deny"
    condition {
      test     = "Bool"
      values   = [false]
      variable = "aws:MultiFactorAuthPresent"
    }
    not_actions = [
      "sts:GetSessionToken",
      "iam:ResyncMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:ListUsers",
      "iam:ListServiceSpecificCredentials",
      "iam:ListSSHPublicKeys",
      "iam:ListMFADevices",
      "iam:ListAccountAliases",
      "iam:ListAccessKeys",
      "iam:GetAccountSummary",
      "iam:EnableMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:CreateVirtualMFADevice",
    ]
    resources = ["*"]
  }

  statement {
    sid = "DenyAllSSMAccess"
    effect = "Deny"
    actions = [
      "ssm:GetParameter*"
    ]
    resources = [
      "arn:aws:ssm:*:*:*"
    ]
  }
}

resource "aws_iam_group_policy" "ithc_audit__custom_rules" {
  group  = aws_iam_group.ithc_audit.name
  policy = data.aws_iam_policy_document.custom_ithc_access_rules.json
}
