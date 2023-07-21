module "elasticache_redis" {
  source = "../resource-groups/elasticache-redis"

  cluster_id      = "cluster1"
  engine_version  = "6.3"
  node_type       = "cache.m1.medium"
  num_cache_nodes = 2
  resource_name_prefixes = {
    normal        = "CORE:DEMO"
    hyphens       = "CORE-DEMO"
    hyphens_lower = "core-demo"
  }
  subnet_ids = [
    "subnet-0111111b524f1b0ef"
  ]
  vpc_id = "vpc-0a23487fbd26"
}
