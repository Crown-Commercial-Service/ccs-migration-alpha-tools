variable "additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [{
    groups   = ["system:masters"]
    rolearn  = "arn:aws:iam::@AWS_ACCOUNT@:role/CCS_TechOps_Admin"
    username = "arn:aws:sts::{{AccountID}}:assumed-role/CCS_TechOps_Admin/{{SessionName}}"
    }, {
    groups   = ["eks-console-dashboard-restricted-access-group"]
    rolearn  = "arn:aws:iam::@AWS_ACCOUNT@:role/CCS_Security_RO"
    username = "arn:aws:sts::{{AccountID}}:assumed-role/CCS_Security_RO/{{SessionName}}"
    }, {
    groups   = ["eks-console-dashboard-restricted-access-group"]
    rolearn  = "arn:aws:iam::@AWS_ACCOUNT@:role/CCS_TechOps_RO"
    username = "arn:aws:sts::{{AccountID}}:assumed-role/CCS_TechOps_RO/{{SessionName}}"
  }]
}

variable "additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "karpenter_role_arn" {
  description = "ARN for the Karpenter role"
  type        = string
}