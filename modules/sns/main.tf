resource "aws_sns_topic" "route53_notifications" {
  name = "Route53Notification"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.route53_notifications.arn
  protocol  = "email"
  endpoint  = "andrew.hemming@redrockconsulting.co.uk"
}
