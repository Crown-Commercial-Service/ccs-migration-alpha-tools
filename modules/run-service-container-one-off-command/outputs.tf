output "ecs_operations_policy_document_json" {
  description = "JSON describing an IAM policy to allow ECS operations necessary to mange and run tasks"
  value       = data.aws_iam_policy_document.ecs_operations.json
}
