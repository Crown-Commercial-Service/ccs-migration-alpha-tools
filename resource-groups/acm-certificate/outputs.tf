output "certificate_arn" {
  description = "ARN of the certificate created"
  value       = aws_acm_certificate_validation.validation.certificate_arn
}
