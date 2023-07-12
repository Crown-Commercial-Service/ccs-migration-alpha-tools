resource "aws_dynamodb_table" "transfer_list" {
  name         = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}-TRANSFER-LIST"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"

  attribute {
    name = "PK"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-DB-${upper(var.migrator_name)}"
  }
}

data "aws_iam_policy_document" "put_transfer_list_item" {
  version = "2012-10-17"

  statement {
    sid = "AllowPut${replace(var.migrator_name, "-", "")}TransferListItem"

    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.transfer_list.arn
    ]
  }
}

data "aws_iam_policy_document" "update_transfer_list_item" {
  version = "2012-10-17"

  statement {
    sid = "AllowUpdate${replace(var.migrator_name, "-", "")}TransferListItem"

    effect = "Allow"

    actions = [
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.transfer_list.arn
    ]
  }
}
