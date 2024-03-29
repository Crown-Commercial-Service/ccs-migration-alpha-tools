# Resources to enable the use of the scripts/run_service_container_one_off_command/run_command.py
# facility.
#
locals {
  service_name_hyphens = replace(var.service.name, "_", "-")
  service_name_no_punc = replace(var.service.name, "/[_-]/", "")
}

resource "aws_iam_group" "run_service_command" {
  name = "run-${local.service_name_hyphens}-service-command"
}

data "aws_iam_policy_document" "ecs_operations" {
  version = "2012-10-17"

  statement {
    sid = "AllowDescribeServices"

    effect = "Allow"

    actions = [
      "ecs:DescribeServices"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        var.service.cluster
      ]
    }
  }

  statement {
    sid = "AllowDescribeTasks"

    effect = "Allow"

    actions = [
      "ecs:DescribeTasks"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        var.service.cluster
      ]
    }
  }

  statement {
    sid = "AllowPassEcsExecRole"

    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      var.ecs_execution_role_arn,

    ]
  }
}

data "aws_iam_policy_document" "run_task" {
  statement {
    sid = "AllowRun${local.service_name_no_punc}Task"

    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      var.service.task_definition
    ]
  }
}

data "aws_iam_policy_document" "run_service_command" {
  source_policy_documents = [
    data.aws_iam_policy_document.ecs_operations.json,
    data.aws_iam_policy_document.run_task.json,
  ]
}

resource "aws_iam_policy" "run_service_command" {
  name   = "run-${local.service_name_hyphens}-service-command"
  policy = data.aws_iam_policy_document.run_service_command.json
}

resource "aws_iam_group_policy_attachment" "run_service_command" {
  group      = aws_iam_group.run_service_command.name
  policy_arn = aws_iam_policy.run_service_command.arn
}
