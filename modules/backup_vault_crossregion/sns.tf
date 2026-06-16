resource "aws_sns_topic" "backup_failure_alerts" {
  name = "aws-backup-failure-alerts"
}

resource "aws_sns_topic_policy" "backup_alerts_policy" {
  arn    = aws_sns_topic.backup_failure_alerts.arn
  policy = data.aws_iam_policy_document.backup_sns.json
}

resource "aws_sns_topic_subscription" "incidentio" {
  count     = var.incidentio_endpoint != "" ? 1 : 0
  topic_arn = aws_sns_topic.backup_failure_alerts.arn
  protocol  = "https"
  endpoint  = "${var.incidentio_endpoint}?${var.incidentio_querystring}"
}
