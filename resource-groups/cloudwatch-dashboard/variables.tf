variable "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch Dashboard"
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS Cluster"
  type        = string
}

variable "region" {
  description = "The region in which the CloudWatch Dashboard should be created (should match where current instances reside)"
  type        = string
}

variable "ec2_instance_ids" {
  description = "The ID(s) of the EC2 instances you wish to monitor (must be in list format)"
  type        = list(string)
}

variable "ecs_service_names" {
  description = "The name(s) of the ECS Services you wish to monitor (must be in list format)"
  type        = list(string)
}

variable "load_balancer_identifiers" {
  description = "List of strings for the Load Balancer identifiers"
  type        = list(string)
}

variable "rds_instance_names" {
  description = "List of strings for the names of RDS instances you wish to gain insights for"
  type        = list(string)
}
