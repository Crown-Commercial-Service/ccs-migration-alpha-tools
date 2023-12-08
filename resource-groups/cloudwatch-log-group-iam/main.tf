data "aws_iam_policy_document" "write_log_group" {
  version = "2012-10-17"

  statement {
    sid = "DescribeAllLogGroups"

    actions = [
      "logs:DescribeLogGroups"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }

  statement {
    sid = "CreateLogGroups"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = [
      for g in var.log_group_arns : "${g}:*"
    ]
  }

  statement {
    sid = "PutLogs"
    actions = [
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      for g in var.log_group_arns : "${g}:log-stream:*"
    ]
  }
}
