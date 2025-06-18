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

variable "project" {
  description = "Project name"
}

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

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from"
}
