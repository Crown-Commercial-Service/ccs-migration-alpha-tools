resource "aws_dynamodb_table" "objects_to_migrate" {
  name         = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}-OBJECTS-TO-MIGRATE"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"

  attribute {
    name = "PK"
    type = "S"
  }

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}-OBJECTS-TO-MIGRATE"
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
