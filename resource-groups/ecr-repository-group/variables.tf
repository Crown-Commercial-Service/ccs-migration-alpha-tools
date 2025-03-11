variable "ecr_allow_push_from_jenkins_accounts_actions" {
  type        = list(string)
  description = "The actions to grant the ECR policy for pushing from Jenkins Accounts"
  default     = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:BatchGetImage",
    "ecr:CompleteLayerUpload",
    "ecr:InitiateLayerUpload",
    "ecr:PutImage",
    "ecr:UploadLayerPart",
  ]
}

variable "ecr_jenkins_account_list_with_sandbox" {
  type        = list(string)
  description = "The list of AWS Accounts (including Sandbox) for Jenkins Access"
  default     = ["473251818902", "974531504241", "665505400356"]
}

variable "ecr_jenkins_account_list_without_sandbox" {
  type        = list(string)
  description = "The list of AWS Accounts (excluding Sandbox) for Jenkins Access"
  default     = ["473251818902", "974531504241"]
}

variable "expire_untagged_images_older_than_days" {
  type        = number
  description = "Number of days after which to expire untagged images"
  default     = 14
}

variable "grant_jenkins_sandbox_access" {
  type        = bool
  description = "Boolean value to indicate whether or not to grant the Jenkins Sandbox instance access (defaults to false)"
  default     = false
}

variable "is_ephemeral" {
  type        = bool
  description = "If set to true, indicates that this module is expected to be destroyed as a matter of course (so will set `force_destroy` on aws resources where appropriate)"
  default     = false
}

variable "repository_names" {
  type        = list(string)
  description = "List of names for the repositories to create"
}
