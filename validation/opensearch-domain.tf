module "opensearch_domain" {
  source = "../resource-groups/opensearch-domain"

  domain_name         = "domain"
  ebs_volume_size_gib = 10
  naming_prefix       = "PREFIX:123"
  subnet_ids          = ["subnet-123", "subnet-456"]
  vpc_id              = "vpc-12345"
}
