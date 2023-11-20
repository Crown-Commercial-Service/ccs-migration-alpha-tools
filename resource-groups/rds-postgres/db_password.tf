resource "random_password" "db" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "postgres_connection_password" {
  name        = "${var.db_name}-postgres-connection-password"
  description = "The password for the ${var.db_name} PostgreSQL database"
  type        = "SecureString"
  value       = random_password.db.result
}

resource "aws_ssm_parameter" "postgres_connection_url" {
  name        = "${var.db_name}-postgres-connection-url"
  description = "Connection URL for the ${var.db_name} PostgreSQL database"
  type        = "SecureString"
  value       = "postgresql://${aws_db_instance.db.username}:${random_password.db.result}@${aws_db_instance.db.endpoint}/${aws_db_instance.db.db_name}"
}

data "aws_iam_policy_document" "read_postgres_connection_password_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowRead${replace(var.db_name, "/[-_/]/", "")}DbPasswordSecret"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      aws_ssm_parameter.postgres_connection_password.arn
    ]
  }
}

data "aws_iam_policy_document" "read_postgres_connection_url_ssm" {
  version = "2012-10-17"

  statement {
    sid = "AllowRead${replace(var.db_name, "/[-_/]/", "")}DbUrlSecret"

    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      aws_ssm_parameter.postgres_connection_url.arn
    ]
  }
}
