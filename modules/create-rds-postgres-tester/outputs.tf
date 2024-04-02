output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the task role"
  value       = module.create_tester_user.pass_task_role_policy_document_json
}
