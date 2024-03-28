variable "dist_folder_path" {
  type        = string
  description = "(Relative) path to the folder in which the dist package (zip file) can be found"
}

variable "dist_package_filename" {
  type        = string
  description = "Filename of the dist package which contains the Lambda to distribute"
}

variable "dist_package_hash" {
  type = object({
    base64sha256 = string
    md5          = string
  })
  description = "Hashes for source comparison and triggering of updates"
}

variable "environment_variables" {
  type        = map(any)
  description = "Map of VAR=VALUE pairs to pass into the Lambda's execution space"
  default     = {}
}

variable "ephemeral_storage_size_mb" {
  type        = number
  description = "MB of /tmp space for the Lambda"
  default     = 512
}

variable "function_name" {
  type        = string
  description = "The name to give to the Lambda function"
}

variable "handler" {
  type        = string
  description = "Name of the handler to invoke in the format `module.exportedname`"
  default     = "lambda_function.lambda_handler"
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "lambda_dist_bucket_id" {
  type        = string
  description = "The name of the bucket via through which to distribute the Lambda code"
}

variable "layer_arns" {
  type = list(string)
  default = null
  description = "List of layer ARNs to attach to the lambda"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days for which to keep log entries from this lambda"
  default     = 30
}

variable "runtime" {
  type        = string
  description = "Runtime library for this Lambda"
  default     = "python3.9"
}

variable "runtime_memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = 512
}

variable "timeout_seconds" {
  type        = number
  description = "The number of seconds to wait for a response from the Lambda"
  default     = 30
}
