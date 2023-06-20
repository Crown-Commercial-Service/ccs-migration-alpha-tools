variable "cluster_name" {
  type        = string
  description = "Name to give to this ECS Cluster"
}

/* This should be declared outside this module - at the top level - and
   passed in, to avoid circular dependencies with the various instances
   of the balanced-ecs-service modules
*/
variable "execution_role" {
  type = object({
    arn  = string,
    name = string
  })
  description = "ARN and name of the IAM role created for ECS Execution"
}

variable "execution_role_policy_docs" {
  type        = map(string)
  description = "Map of JSON policy documents keyed by a distilled description of the purpose of each"
}
