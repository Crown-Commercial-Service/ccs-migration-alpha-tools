output "clients_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the Redis cluster"
  value       = aws_security_group.cluster_clients.id
}

output "redis_host" {
  description = "Connection host for the Redis cluster"
  value       = aws_elasticache_replication_group.rg.primary_endpoint_address
}

output "redis_port" {
  description = "Connection port for the Redis cluster"
  value       = aws_elasticache_replication_group.rg.port
}

output "redis_uri" {
  description = "Connection URI for the Redis cluster"
  value       = ":${random_password.auth_token.result}@${aws_elasticache_replication_group.rg.primary_endpoint_address}:${aws_elasticache_replication_group.rg.port}"
}
