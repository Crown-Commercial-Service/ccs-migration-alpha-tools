output "ithc_audit_iam_user_arn" {
  description = "ARN of the IAM user created for ITHC audit"
  value       = aws_iam_user.ithc_audit.arn
}
