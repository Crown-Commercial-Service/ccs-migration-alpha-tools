module "gpaas_s3_migrator" {
  source = "../modules/gpaas-s3-migrator"

  lambda_dist_bucket_id                 = "some-bucket"
  migration_workers_maximum_concurrency = 2
  migrator_name                         = "doc-migrator"
  resource_name_prefixes = {
    normal        = "PREFIX:123"
    hyphens       = "PREFIX-123"
    hyphens_lower = "prefix-n123"
  }
  target_bucket_id                                 = "bucket123"
  target_bucket_write_objects_policy_document_json = "{\"json\":\"dummy\"}"
}
