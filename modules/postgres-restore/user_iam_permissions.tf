# Helper group to enable operatives to run this restore
resource "aws_iam_group" "run_restore" {
  name = "run-${var.restore_name}-postgres-restore"
}

data "aws_iam_policy_document" "run_restore" {
  version = "2012-10-17"

  statement {
    sid = "AllowGetTaggedResources"

    effect = "Allow"

    actions = [
      "tag:GetResources",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowStartPerformRestoreSfn"

    effect = "Allow"

    actions = [
      "states:StartExecution",
    ]

    resources = [
      aws_sfn_state_machine.perform_migration.arn
    ]
  }

  statement {
    sid = "AllowDescribePerformRestoreSfnExecution"

    effect = "Allow"

    actions = [
      "states:DescribeExecution",
    ]

    resources = [
      "${replace(aws_sfn_state_machine.perform_restore.arn, "stateMachine", "execution")}:*"
    ]
  }
}

resource "aws_iam_policy" "run_restore" {
  name   = "run-${var.restore_name}-postgres-restore"
  policy = data.aws_iam_policy_document.run_restore.json
}

resource "aws_iam_group_policy_attachment" "run_restore" {
  group      = aws_iam_group.run_restore.name
  policy_arn = aws_iam_policy.run_restore.arn
}
