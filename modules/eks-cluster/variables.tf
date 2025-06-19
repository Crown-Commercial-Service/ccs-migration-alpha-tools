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
    groups   = ["system:masters"]
    rolearn  = "arn:aws:iam::@AWS_ACCOUNT@:role/CCS_TechOps_GitHub_Actions"
    username = "arn:aws:sts::{{AccountID}}:assumed-role/CCS_TechOps_GitHub_Actions/{{SessionName}}"
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

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group"
  type        = string
  default     = "SPOT"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "instance_types" {
  description = "List of instance types associated with the EKS Node Group"
  type        = list(string)
  default = [
    "t2.medium"
  ]
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "max_unavailable" {
  description = "Desired max number of unavailable worker nodes during node group update"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "public_cidr_allowlist" {
  description = "Allowed public CIDR"
  type        = list(string)
  default = [
    "51.149.8.0/25",    # CCS IPs
    "54.220.137.216/32" # Muhammad bastion IP
  ]
}

variable "private_subnets" {
  description = "Map of subnets to associate with the EKS cluster"
  type = map(object({
    availability_zone = string
    cidr_block        = string
    id                = string
  }))
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}
