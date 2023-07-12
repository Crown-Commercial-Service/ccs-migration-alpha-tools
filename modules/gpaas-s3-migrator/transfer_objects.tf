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
            "ResultPath": null,
            "Next": "Transfer one object"
          },
          "Transfer one object": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "${module.transfer_one_object_lambda.function_arn}",
              "Payload": {
                "gpaas_service_key_ssm_param_name": "${aws_ssm_parameter.gpaas_service_key.name}",
                "key.$" : "$.Key",
                "source_bucket_id.$" : "$.Bucket",
                "target_bucket_id" : "${var.target_bucket_id}"
              }
            },
            "ResultPath": null,
            "Next": "Update status"
          },
          "Update status": {
            "Type": "Task",
            "Resource": "arn:aws:states:::dynamodb:updateItem",
            "Parameters": {
              "TableName": "${aws_dynamodb_table.transfer_list.name}",
              "Key": {
                "PK" : {"S.$" : "$.PK"}
              },
              "UpdateExpression": "SET #status = :status",
              "ExpressionAttributeNames": {
                "#status" : "Status"
              },
              "ExpressionAttributeValues": {
                ":status": {"S" : "copied"}
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

resource "aws_iam_role_policy" "transfer_objects_sfn__invoke_transfer_one_object_lambda" {
  name   = "invoke-transfer-one-object-lambda"
  role   = aws_iam_role.transfer_objects_sfn.id
  policy = module.transfer_one_object_lambda.invoke_lambda_iam_policy_json
}


module "transfer_one_object_lambda" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "transfer_one_object.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.transfer_one_object_lambda_zip.output_base64sha256
    md5          = data.archive_file.transfer_one_object_lambda_zip.output_md5
  }
  function_name         = "${var.migrator_name}-transfer-one-object"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
}

data "archive_file" "transfer_one_object_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/transfer_one_object"
  output_path = "${path.module}/lambdas/dist/transfer_one_object.zip"
}

resource "aws_iam_role_policy" "transfer_one_object_lambda__read_gpaas_service_key_ssm" {
  name   = "read-gpaas-service-key-ssm"
  role   = module.transfer_one_object_lambda.service_role_name
  policy = data.aws_iam_policy_document.read_gpaas_service_key_ssm.json
}

resource "aws_iam_role_policy" "transfer_one_object_lambda__write_target_bucket" {
  name   = "write-target-bucket"
  role   = module.transfer_one_object_lambda.service_role_name
  policy = var.target_bucket_write_objects_policy_document_json
}
