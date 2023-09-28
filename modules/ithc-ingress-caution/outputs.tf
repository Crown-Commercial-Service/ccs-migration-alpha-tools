output "ithc_audit_iam_user_arn" {
  description = "ARN of the IAM user created for ITHC audit"
  value       = aws_iam_user.ithc_audit.arn
}

output "vpc_scanner_public_dns" {
  description = "Public DNS name of the VPC Scanner instance"
  value       = aws_instance.vpc_scanner.public_dns
}
