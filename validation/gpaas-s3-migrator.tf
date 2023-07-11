module "gpaas_s3_migrator" {
  source = "../modules/gpaas-s3-migrator"

  lambda_dist_bucket_id = "some-bucket"
  migrator_name         = "doc-migrator"
  resource_name_prefixes = {
    normal        = "PREFIX:123"
    hyphens       = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
}
