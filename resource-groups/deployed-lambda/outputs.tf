output "function_arn" {
  description = "ARN of the deployed function"
  value       = aws_lambda_function.function.arn
}

output "invoke_lambda_iam_policy_json" {
  description = "JSON describing an IAM Policy which allows invocation of this Lambda"
  value       = data.aws_iam_policy_document.invoke_lambda.json
}

output "service_role_name" {
  description = "Name of the service role assigned to this Lambda"
  value       = aws_iam_role.lambda_exec.name
}
