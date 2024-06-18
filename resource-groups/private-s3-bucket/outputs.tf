output "bucket_domain_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_id" {
  description = "Full name of created bucket"
  value       = aws_s3_bucket.bucket.id
}

output "delete_objects_policy_document_json" {
  description = "JSON describing an IAM policy which allows objects in this bucket to be deleted"
  value       = data.aws_iam_policy_document.delete_objects.json
}

output "read_objects_policy_document_json" {
  description = "JSON describing an IAM policy which allows objects in this bucket to be read"
  value       = data.aws_iam_policy_document.read_objects.json
}

output "write_objects_policy_document_json" {
  description = "JSON describing an IAM policy which allows objects in this bucket to be written"
  value       = data.aws_iam_policy_document.write_objects.json
}
