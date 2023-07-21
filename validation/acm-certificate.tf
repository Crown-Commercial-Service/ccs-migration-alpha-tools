module "acm_certificate" {
  source = "../resource-groups/acm-certificate"

  domain_name    = "example.xyz"
  hosted_zone_id = "Z0123456789"
}
