# Helper group to enable operatives to run this migrator
resource "aws_iam_group" "run_migrator" {
  name = "run-${var.migrator_name}-postgres-migrator"
}

data "aws_iam_policy_document" "run_migrator" {
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
    sid = "AllowStartPerformMigrationSfn"

    effect = "Allow"

    actions = [
      "states:StartExecution",
    ]

    resources = [
      aws_sfn_state_machine.perform_migration.arn
    ]
  }

  statement {
    sid = "AllowDescribePerformMigrationSfnExecution"

    effect = "Allow"

    actions = [
      "states:DescribeExecution",
    ]

    resources = [
      "${replace(aws_sfn_state_machine.perform_migration.arn, "stateMachine", "execution")}:*"
    ]
  }
}

resource "aws_iam_group_policy" "run_migrator" {
  name   = "run-migrator"
  group  = aws_iam_group.run_migrator.name
  policy = data.aws_iam_policy_document.run_migrator.json
}
