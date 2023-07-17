resource "aws_dynamodb_table" "objects_to_migrate" {
  name         = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}-OBJECTS-TO-MIGRATE"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "Status"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  global_secondary_index {
    hash_key = "Status"
    name     = "CopyStatusIndex"
    non_key_attributes = [
      "Bucket",
      "Key"
    ]
    projection_type = "INCLUDE"
  }

  tags = {
    Name                = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}-OBJECTS-TO-MIGRATE"
    GPaasS3MigratorName = var.migrator_name
  }
}

data "aws_iam_policy_document" "put_objects_to_migrate_item" {
  version = "2012-10-17"

  statement {
    sid = "AllowPut${replace(var.migrator_name, "-", "")}ObjectsToMigrateItem"

    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.objects_to_migrate.arn
    ]
  }
}

data "aws_iam_policy_document" "update_objects_to_migrate_item" {
  version = "2012-10-17"

  statement {
    sid = "AllowUpdate${replace(var.migrator_name, "-", "")}ObjectsToMigrateItem"

    effect = "Allow"

    actions = [
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.objects_to_migrate.arn
    ]
  }
}
