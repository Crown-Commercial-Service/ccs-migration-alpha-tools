# Helper group to enable operatives to run this migrator
resource "aws_iam_group" "run_migrator" {
  name = "run-${var.migrator_name}-s3-migrator"
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
    sid = "AllowStartCompileObjectsSfn"

    effect = "Allow"

    actions = [
      "states:StartExecution",
    ]

    resources = [
      aws_sfn_state_machine.compile_objects_to_migrate.arn
    ]
  }

  statement {
    sid = "AllowDescribeStartCompileObjectsSfnExecution"

    effect = "Allow"

    actions = [
      "states:DescribeExecution",
    ]

    resources = [
      "${replace(aws_sfn_state_machine.compile_objects_to_migrate.arn, "stateMachine", "execution")}:*"
    ]
  }

  statement {
    sid = "AllowQueryObjectsToMigrateTableCopyStatusIndex"

    effect = "Allow"

    actions = [
      "dynamodb:Query",
    ]

    resources = [
      "${aws_dynamodb_table.objects_to_migrate.arn}/index/CopyStatusIndex"
    ]
  }
}

resource "aws_iam_group_policy" "run_migrator" {
  name   = "run-migrator"
  group  = aws_iam_group.run_migrator.name
  policy = data.aws_iam_policy_document.run_migrator.json
}
