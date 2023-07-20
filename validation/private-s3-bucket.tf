module "private_s3_bucket" {
  source = "../resource-groups/private-s3-bucket"

  bucket_name  = "bucket123"
  is_ephemeral = true
  versioning   = true
}
