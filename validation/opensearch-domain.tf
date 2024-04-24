module "opensearch_domain" {
  source = "../resource-groups/opensearch-domain"

  domain_name         = "domain"

  ebs_volume_size_gib = 10
  engine_version      = "OpenSearch_1.4"
  instance_type       = "m1.medium.search"
  resource_name_prefixes = {
    normal        = "PREFIX:123"
    hyphens       = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  subnet_ids = ["subnet-123", "subnet-456"]
  vpc_id     = "vpc-12345"
  enable_search_slow_logs = false
  enable_index_slow_logs = false
  enable_error_logs = false
  enable_audit_logs = false
  log_group_name_search_slow_logs = "opensearch-search-slow"
  log_group_name_index_slow_logs = "opensearch-index-slow"
  log_group_name_error_logs = "opensearch-error"
  log_group_name_audit_logs = "opensearch-audit"
}
