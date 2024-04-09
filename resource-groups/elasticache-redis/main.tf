resource "random_password" "auth_token" {
  length  = 64
  special = false
}

resource "aws_elasticache_replication_group" "rg" {
  at_rest_encryption_enabled  = true
  automatic_failover_enabled  = false
  auth_token                  = random_password.auth_token.result
  description                 = "replication group"
  engine                      = "redis"
  engine_version              = var.engine_version
  replication_group_id        = "${var.cluster_id}-rep-group"
  node_type                   = var.node_type
  num_cache_clusters          = var.num_cache_nodes
  parameter_group_name        = var.elasticache_cluster_parameter_group_name
  port                        = 6379
  security_group_ids          = [aws_security_group.cluster.id]
  subnet_group_name           = aws_elasticache_subnet_group.cluster.name
  transit_encryption_enabled = true

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

resource "aws_elasticache_cluster" "cluster" {
  apply_immediately    = var.elasticache_cluster_apply_immediately
  cluster_id           = var.cluster_id
  replication_group_id = aws_elasticache_replication_group.rg.id
}

locals {
  cluster_id_upper = upper(var.cluster_id)
}

resource "aws_elasticache_subnet_group" "cluster" {
  name       = "${var.resource_name_prefixes.hyphens}-${local.cluster_id_upper}"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "cluster" {
  name        = "${var.resource_name_prefixes.hyphens}-${local.cluster_id_upper}"
  description = "Redis instances for ${var.cluster_id}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-${local.cluster_id_upper}"
  }
}

resource "aws_security_group" "cluster_clients" {
  name        = "${var.resource_name_prefixes.hyphens}-${local.cluster_id_upper}-CLIENTS"
  description = "Entities permitted to access the Redis cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.hyphens}-${local.cluster_id_upper}-CLIENTS"
  }
}

resource "aws_security_group_rule" "cluster_in" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow 6379 inwards to Redis from clients"

  from_port                = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster_clients.id
  to_port                  = 6379
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_clients_out" {
  security_group_id = aws_security_group.cluster_clients.id
  description       = "Allow 6379 outwards from clients to Redis"

  from_port                = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 6379
  type                     = "egress"
}
