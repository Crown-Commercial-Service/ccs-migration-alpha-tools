output "pull_repo_images_policy_document_json" {
  description = "JSON describing an IAM policy which allows each of the repos' images to be pulled"
  value       = data.aws_iam_policy_document.pull_repo_images.json
}

output "repository_urls" {
  description = "URLs of the repository (as compatible with Docker CLI commands)"
  value = {
    for name, repo in aws_ecr_repository.repo : name => repo.repository_url
  }
}
