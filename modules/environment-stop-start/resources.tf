resource "aws_dynamodb_table" "start_stop" {
  name     = "start-stop"

  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "resources" {
  table_name = aws_dynamodb_table.start_stop.name
  hash_key   = aws_dynamodb_table.start_stop.hash_key

  item = jsonencode(var.resources)
}
