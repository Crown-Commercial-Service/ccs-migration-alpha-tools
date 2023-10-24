variable "domain_name" {
  type        = string
  description = "Name to assign to the OpenSearch domain"
}

variable "ebs_volume_size_gib" {
  type        = number
  description = "Size (in GiB) of the EBS volumes to attach to each search instance"
}

variable "engine_version" {
  type        = string
  description = "Version of OpenSearch engine to deploy"
  default     = "OpenSearch_1.3" # Eschewed more recent 2.5 because DMP in GPaaS is running v1 AFAIK
}

variable "instance_count" {
  type        = number
  description = "Number of instances in the cluster"
  default     = 2
}

variable "instance_type" {
  type        = string
  description = "Type of compute instance to provide for the OpenSearch domain"
  default     = "t3.small.search"
}

variable "resource_name_prefixes" {
  type = object({
    normal        = string,
    hyphens       = string,
    hyphens_lower = string
  })
  description = "Prefix to apply to resources in AWS; options provided to satisfy divergent naming requirements across AWS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of subnets into which to place the OpenSearch domain access points"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the service"
}
