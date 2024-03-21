variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "db_name" {
  type = string
  description = "Database name"
}

variable "lambda_dist_bucket_id" {
  description = "The name of the bucket via through which to distribute the Lambda code"
  type = string
}

variable "rds_host" {
  type = string
  description = "RDS host"
}
