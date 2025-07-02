variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "aws_account" {
  description = "The AWS account ID"
  type        = string
}

variable "aws_ecr_registry" {
  description = "Name of the ECR registry"
  type        = string
}

variable "external_secret_description" {
  description = "The description of the secret"
  type        = string
}

variable "external_secrets_image_tag" {
  description = "The image tag to use for the external secrets operator"
  type        = string
}

variable "external_secrets_namespace" {
  description = "Namespace to create the external secrets in"
  type        = string
}

variable "external_secrets_operator_namespace" {
  description = "Namespace to install external secrets operator"
  type        = string
  default     = "external-secrets-operator"
}

variable "external_secrets_service_account" {
  description = "The name of the external secrets operator service account"
  type        = string
  default     = "external-secrets-agent"
}

variable "external_secret_type" {
  description = "The type of the secret being added"
  type        = string
}