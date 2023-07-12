resource "aws_sfn_state_machine" "transfer_objects" {
  name     = "${var.migrator_name}-transfer-objects"
  role_arn = aws_iam_role.transfer_objects_sfn.arn

  definition = <<EOF
{
  "Comment": "Transfer several objects from the GPaaS bucket into the native bucket",
  "StartAt": "Dummy",
  "States": {
    "Dummy": {
      "Type": "Succeed"
    }
  }
}
EOF
}

resource "aws_iam_role" "transfer_objects_sfn" {
  name = "${var.migrator_name}-transfer-objects-sfn"

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

data "aws_iam_policy_document" "start_transfer_objects_sfn" {
  version = "2012-10-17"

  statement {
    sid = "AllowStartTransferObjectsSFN"

    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.transfer_objects.arn
    ]
  }
}
