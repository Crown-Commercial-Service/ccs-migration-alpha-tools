output "write_log_group_policy_document_json" {
  description = "JSON describing an IAM policy which allows all log groups to be written to"
  value       = data.aws_iam_policy_document.write_log_group.json
}
