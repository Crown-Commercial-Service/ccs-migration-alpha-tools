resource "aws_sns_topic" "rds_event_subscription_sns_topic" {
  count             = var.rds_event_subscription_enabled ? 1 : 0
  name              = "${var.db_name}-sns-topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "rds_event_subscription_sns_topic_subscription" {
  count     = var.rds_event_subscription_enabled ? 1 : 0
  endpoint  = var.rds_event_subscription_email_endpoint
  protocol  = "email"
  topic_arn = aws_sns_topic.rds_event_subscription_sns_topic[count.index].arn
}

resource "aws_db_event_subscription" "rds_event_subscription" {
  count     = var.rds_event_subscription_enabled ? 1 : 0
  name      = "${var.db_name}-event-subscription"
  sns_topic = aws_sns_topic.rds_event_subscription_sns_topic[count.index].arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.db.identifier]

  event_categories = var.rds_event_subscription_categories
}
