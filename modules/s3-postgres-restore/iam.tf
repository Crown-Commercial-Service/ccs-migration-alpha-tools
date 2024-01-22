data "aws_iam_policy_document" "download_task" {
  version = "2012-10-17"

  statement {
    sid = "AllowS3Download"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::digitalmarketplace-database-backups-nft",
      "arn:aws:s3:::digitalmarketplace-database-backups-nft/*"
    ]
  }
}

resource "aws_iam_policy" "download_task" {
  name = "postgres-s3-restore"
  policy = data.aws_iam_policy_document.download_task.json
}

resource "aws_iam_role_policy_attachment" "download_task" {
  role       = "pg_restore_api_download-ecs-task"
  policy_arn = aws_iam_policy.download_task.arn
}
