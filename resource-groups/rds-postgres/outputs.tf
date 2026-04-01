# Note that we support two types of app configuration here:
#  1. For apps which expect a single db connection URL (incorporating creds, endpoint, etc)
#     we write an SSM parameter and provide its ARN (postgres_connection_url_ssm_parameter_arn)
#     along with some policy JSON to allow access to this
#     (read_postgres_connection_url_ssm_policy_document_json) - This is the preferred method
#     of configuration
#  2. Some apps instead expect to receive the components of the db connection as individual
#     properties within the CloudFoundry VCAP_SERVICES magic config variable. So we also
#     provide those properties here as module outputs (db_connection_*), even though methods
#     1 and 2 here are mutually redundant.
#
output "availability_zone" {
  description = "Availability zone of the RDS instance"
  value       = aws_db_instance.db.availability_zone
}

output "arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.db.arn
}

output "db_clients_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the DB"
  value       = aws_security_group.db_clients.id
}

output "db_connection_host" {
  description = "Hostname of the db instance"
  value       = aws_db_instance.db.address
}

output "db_connection_name" {
  description = "Name of the actual db"
  value       = aws_db_instance.db.db_name
}

output "db_connection_password" {
  description = "Password to connect to the db"
  sensitive   = true
  value       = random_password.db.result
}

output "db_connection_port" {
  description = "Port on which to connect to the db instance"
  value       = aws_db_instance.db.port
}

output "db_connection_username" {
  description = "Username to connect to the db"
  sensitive   = true
  value       = aws_db_instance.db.username
}

output "postgres_connection_password_ssm_parameter_arn" {
  description = "ARN of the SSM parameter which contains the DB Connection password"
  value       = aws_ssm_parameter.postgres_connection_password.arn
}

output "postgres_connection_url_ssm_parameter_arn" {
  description = "ARN of the SSM parameter which contains the DB Connection URL"
  value       = aws_ssm_parameter.postgres_connection_url.arn
}

output "rds_db_endpoint" {
  description = "Endpoint to which to connect for access to this database"
  value       = aws_db_instance.db.endpoint
}

output "read_postgres_connection_password_ssm_policy_document_json" {
  description = "JSON policy doc allowing read access to the DB Connection password parameter in SSM"
  value       = data.aws_iam_policy_document.read_postgres_connection_password_ssm.json
}

output "read_postgres_connection_url_ssm_policy_document_json" {
  description = "JSON policy doc allowing read access to the DB Connection URL parameter in SSM"
  value       = data.aws_iam_policy_document.read_postgres_connection_url_ssm.json
}
