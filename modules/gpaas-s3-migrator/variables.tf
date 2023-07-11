variable "lambda_dist_bucket_id" {
  description = "ID of the bucket through which to distribute Lambda function source"
  type        = string
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
