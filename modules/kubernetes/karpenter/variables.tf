variable "namespace" {
  type        = string
  description = "The namespace for Karpenter"
  default     = "karpenter"
}

variable "aws_account" {}
variable "aws_ecr_registry" {}
variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "environment" {}
variable "instance_profile_name" {}