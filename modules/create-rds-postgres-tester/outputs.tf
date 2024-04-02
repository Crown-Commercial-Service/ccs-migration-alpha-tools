output "pass_task_role_policy_document_json" {
  description = "JSON describing an IAM policy which allows passage of the task role"
  value       = module.create_tester_user.pass_task_role_policy_document_json
}

output "write_task_logs_policy_document_json" {
  description = "JSON describing an IAM policy which allows the task's log streams to be written"
  value       = module.create_tester_user.write_task_logs_policy_document_json
}
