output "certificate_arn" {
  description = "ARN of the certificate created"
  value       = aws_acm_certificate.cert.arn
}
