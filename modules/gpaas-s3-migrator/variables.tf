variable "aws_account_id" {
  type        = string
  description = "ID of the account into which deployments are performed"
}

variable "aws_region" {
  type        = string
  description = "Region for resource deployment"
}

variable "lambda_dist_bucket_id" {
  description = "ID of the bucket through which to distribute Lambda function source"
  type        = string
}

# Beware setting this too high; you will hit S3 API rate limits. 4 seems healthy.
variable "migration_workers_maximum_concurrency" {
  description = "Maximum number of concurrent Lambda functions performing the copying"
  type        = number
  default     = 4
}

variable "migrator_name" {
  description = "A name to distinguish this migrator"
  type        = string
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "target_bucket_id" {
  description = "ID of the bucket into which to copy the objects from GPaaS"
  type        = string
}

variable "target_bucket_write_objects_policy_document_json" {
  description = "JSON describing a policy to allow the writing of objects to the target bucket"
  type        = string
}
