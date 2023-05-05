output "opensearch_clients_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the VPC endpoint for this OpenSearch domain"
  value       = aws_security_group.opensearch_clients.id
}

output "opensearch_endpoint" {
  description = "Endpoint to which to connect for access to this OpenSearch domain"
  value       = aws_opensearch_domain.domain.endpoint
}
