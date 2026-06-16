resource "aws_sns_topic" "backup_failure_alerts" {
  name = "aws-backup-failure-alerts"
}

resource "aws_sns_topic" "lambda_failure_alerts" {
  name = "lambda-backup-copy-to-vault-error-alerts"
}

resource "aws_sns_topic_policy" "backup_alerts_policy" {
  arn    = aws_sns_topic.backup_failure_alerts.arn
  policy = data.aws_iam_policy_document.backup_sns.json
}

resource "aws_sns_topic_policy" "lambda_failure_policy" {
  arn    = aws_sns_topic.lambda_failure_alerts.arn
  policy = data.aws_iam_policy_document.lambda_sns.json
}

resource "aws_sns_topic_subscription" "incidentio_backups" {
  count     = var.incidentio_endpoint != "" ? 1 : 0
  topic_arn = aws_sns_topic.backup_failure_alerts.arn
  protocol  = "https"
  endpoint  = "${var.incidentio_endpoint}?${var.incidentio_querystring}"
}

resource "aws_sns_topic_subscription" "incidentio_lambda" {
  count     = var.incidentio_endpoint != "" ? 1 : 0
  topic_arn = aws_sns_topic.lambda_failure_alerts.arn
  protocol  = "https"
  endpoint  = "${var.incidentio_endpoint}?${var.incidentio_querystring}"
}
