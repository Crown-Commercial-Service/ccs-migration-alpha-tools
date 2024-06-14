output "clients_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the Redis cluster"
  value       = aws_security_group.cluster_clients.id
}

output "redis_auth_token" {
  description = "Auth token for the Redis cluster"
  sensitive   = true
  value       = var.replication_group_enabled != false ? random_password.auth_token[0].result : ""
}

output "redis_host" {
  description = "Connection host for the Redis cluster"
  value       = var.replication_group_enabled != false ? aws_elasticache_replication_group.rg[0].primary_endpoint_address : aws_elasticache_cluster.cluster.cache_nodes[0]["address"]
}

output "redis_port" {
  description = "Connection port for the Redis cluster"
  value       = var.replication_group_enabled != false ? aws_elasticache_replication_group.rg[0].port : aws_elasticache_cluster.cluster.cache_nodes[0]["port"]
}

output "redis_uri" {
  description = "Connection URI for the Redis cluster"
  value       = var.replication_group_enabled != false ? ":${random_password.auth_token[0].result}@${aws_elasticache_replication_group.rg[0].primary_endpoint_address}:${aws_elasticache_replication_group.rg[0].port}" : "${aws_elasticache_cluster.cluster.cache_nodes[0]["address"]}:${aws_elasticache_cluster.cluster.cache_nodes[0]["port"]}"
}
