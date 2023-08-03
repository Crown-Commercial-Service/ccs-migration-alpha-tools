# Dynamo table with at most one item in it. Presence of item indicates that a migration was already run
# and so therefore cannot be run again
resource "aws_dynamodb_table" "migrator_lock" {
  name         = "${var.resource_name_prefixes.hyphens}-PGMIGRATOR-${upper(var.migrator_name)}-LOCK"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Locked"

  attribute {
    name = "Locked"
    type = "S"
  }

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}-LOCK"
  }
}
