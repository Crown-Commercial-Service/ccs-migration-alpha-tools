output "clients_security_group_id" {
  description = "ID of Security Group, membership of which grants routing access to the Redis cluster"
  value       = aws_security_group.cluster_clients.id
}

output "redis_uri" {
  description = "Connection URI for the Redis cluster"
  value       = "${aws_elasticache_cluster.cluster.cache_nodes[0]["address"]}:${aws_elasticache_cluster.cluster.cache_nodes[0]["port"]}"
}
