resource "aws_sfn_state_machine" "transfer_objects" {
  name     = "${var.migrator_name}-transfer-objects"
  role_arn = aws_iam_role.transfer_objects_sfn.arn

  definition = <<EOF
{
  "Comment": "Transfer several objects from the GPaaS bucket into the native bucket",
  "StartAt": "Map for each Transfer Item",
  "States": {
    "Map for each Transfer Item": {
      "Type": "Map",
      "ItemsPath": "$.TransferItems",
      "ItemProcessor": {
        "StartAt": "Note Execution ID",
        "States": {
          "Note Execution ID": {
            "Type": "Task",
            "Resource": "arn:aws:states:::dynamodb:updateItem",
            "Parameters": {
              "TableName": "${aws_dynamodb_table.transfer_list.name}",
              "Key": {
                "PK" : {"S.$" : "$.PK"}
              },
              "UpdateExpression": "SET #executionid = :executionid",
              "ExpressionAttributeNames": {
                "#executionid" : "ExecutionId"
              },
              "ExpressionAttributeValues": {
                ":executionid": {"S.$" : "$$.Execution.Id"}
              }
            },
            "End": true
          }
        }
      },
      "End": true
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

resource "aws_iam_role_policy" "transfer_objects_sfn__update_transfer_list_item" {
  name   = "update-transfer-list-item"
  role   = aws_iam_role.transfer_objects_sfn.name
  policy = data.aws_iam_policy_document.update_transfer_list_item.json
}
