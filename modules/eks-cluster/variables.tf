variable "project" {
  description = "Project name"
}

variable "k8s_version" {
  description = "Kubernetes version"
}

variable "service_ipv4_cidr" {}

variable "public_cidr_allowlist" {
  description = "Allowed public CIDR"
  type        = list(string)
  default = [
    "0.0.0.0/0"
  ]
}

variable "private_subnets" {
  description = "Map of subnets to associate with the EKS cluster"
  type = map(object({
    availability_zone = string
    cidr_block        = string
  }))
}