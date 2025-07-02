data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "eks-${var.application_name}"
}

data "aws_kms_key" "default_ssm_key" {
  key_id = "alias/aws/ssm"
}