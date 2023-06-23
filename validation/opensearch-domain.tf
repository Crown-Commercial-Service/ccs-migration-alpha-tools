module "opensearch_domain" {
  source = "../resource-groups/opensearch-domain"

  domain_name         = "domain"
  ebs_volume_size_gib = 10
  resource_name_prefixes = {
    normal  = "PREFIX:123"
    hyphens = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  subnet_ids = ["subnet-123", "subnet-456"]
  vpc_id     = "vpc-12345"
}
