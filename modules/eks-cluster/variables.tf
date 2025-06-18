variable "capacity_type" {
  description = "The type of EC2 capacity to launch for the EKS node group"
  type        = string
  default     = "SPOT"
}

variable "desired_size" {
  description = "The desired size for the EKS node group"
  type        = number
}

variable "instance_types" {
  description = "The type of EC2 instance to launch for the EKS node group"
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
  description = "The max size for the EKS node group"
  type        = number
}

variable "min_size" {
  description = "The min size for the EKS node group"
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
  description = "The CIDR for the Kubernetes service range"
}
