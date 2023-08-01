# Resources to enable the use of the scripts/update_service/update_service.py
# facility.
resource "aws_iam_group" "run_update_service" {
  name = "run-update-service"
}

data "aws_iam_policy_document" "run_update_service" {
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
        var.ecs_cluster_arn
      ]
    }
  }

  statement {
    sid = "AllowUpdateService"

    effect = "Allow"

    actions = [
      "ecs:UpdateService"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        var.ecs_cluster_arn
      ]
    }
  }
}


resource "aws_iam_policy" "run_update_service" {
  name   = "run-update-service"
  policy = data.aws_iam_policy_document.run_update_service.json
}

resource "aws_iam_group_policy_attachment" "run_update_service" {
  group      = aws_iam_group.run_update_service.name
  policy_arn = aws_iam_policy.run_update_service.arn
}
