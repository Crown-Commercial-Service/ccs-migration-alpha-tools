resource "aws_sfn_state_machine" "compile_objects_to_migrate" {
  name     = "${var.migrator_name}-compile-objects-to-migrate"
  role_arn = aws_iam_role.compile_objects_to_migrate_sfn.arn

  definition = <<EOF
{
  "Comment": "Compile the list of S3 objects to migrate from the GPaaS bucket into the native bucket",
  "StartAt": "Compile objects to migrate",
  "States": {
    "Compile objects to migrate": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${module.compile_objects_to_migrate_lambda.function_arn}"
      },
      "End": true
    }
  }
}
EOF

  tags = {
    GPaasS3MigratorName = var.migrator_name
  }
}

resource "aws_iam_role" "compile_objects_to_migrate_sfn" {
  name = "${var.migrator_name}-compile-objects-to-migrate-sfn"

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

resource "aws_iam_role_policy" "compile_objects_to_migrate_sfn__invoke_compile_objects_to_migrate_lambda" {
  name   = "invoke-compile-objects-to-migrate-lambda"
  role   = aws_iam_role.compile_objects_to_migrate_sfn.id
  policy = module.compile_objects_to_migrate_lambda.invoke_lambda_iam_policy_json
}

module "compile_objects_to_migrate_lambda" {
  source = "../../resource-groups/deployed-lambda"

  dist_folder_path      = "${path.module}/lambdas/dist"
  dist_package_filename = "compile_objects_to_migrate.zip"
  dist_package_hash = {
    base64sha256 = data.archive_file.compile_objects_to_migrate_lambda_zip.output_base64sha256
    md5          = data.archive_file.compile_objects_to_migrate_lambda_zip.output_md5
  }
  environment_variables = {
    GPAAS_SERVICE_KEY_SSM_PARAM_NAME = aws_ssm_parameter.gpaas_service_key.name
    OBJECTS_TO_MIGRATE_TABLE_NAME    = aws_dynamodb_table.objects_to_migrate.name
  }
  function_name         = "${var.migrator_name}-compile-objects-to-migrate"
  lambda_dist_bucket_id = var.lambda_dist_bucket_id
}

data "archive_file" "compile_objects_to_migrate_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/compile_objects_to_migrate"
  output_path = "${path.module}/lambdas/dist/compile_objects_to_migrate.zip"
}

resource "aws_iam_role_policy" "compile_objects_to_migrate_lambda__put_objects_to_migrate_item" {
  name   = "put-objects-to-migrate-item"
  role   = module.compile_objects_to_migrate_lambda.service_role_name
  policy = data.aws_iam_policy_document.put_objects_to_migrate_item.json
}

resource "aws_iam_role_policy" "compile_objects_to_migrate_lambda__read_gpaas_service_key_ssm" {
  name   = "read-gpaas-service-key-ssm"
  role   = module.compile_objects_to_migrate_lambda.service_role_name
  policy = data.aws_iam_policy_document.read_gpaas_service_key_ssm.json
}
