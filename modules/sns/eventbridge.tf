# us-east-1
resource "aws_cloudwatch_event_rule" "route53_create_hosted_zone_us" {
  provider = aws.global-service-region

  name        = "route53-create-hosted-zone-rule-us"
  description = "Capture new Route 53 hosted zone event when it is created in us-east-1"

  event_pattern = jsonencode({
    "source" : [
      "aws.route53"
    ],
    "detail-type" : [
      "AWS Console Sign In via CloudTrail"
    ],
    "detail" : {
      "eventSource" : [
        "route53.amazonaws.com"
      ],
      "eventName" : [
        "CreateHostedZone"
      ]
    }
  })
}

# us-east-1 needs to target the default event bus in eu-west-2
resource "aws_cloudwatch_event_target" "target_eu" {
  provider = aws.global-service-region

  rule = aws_cloudwatch_event_rule.route53_create_hosted_zone_us.name
  arn  = aws_cloudwatch_event_rule.route53_create_hosted_zone_eu.arn
}

# Event rule in eu-west-2 to capture the forwarded event
resource "aws_cloudwatch_event_rule" "route53_create_hosted_zone_eu" {
  name        = "route53-create-hosted-zone-rule-eu"
  description = "Capture Route 53 hosted zone event"

  event_pattern = jsonencode({
    "source" : [
      "aws.route53"
    ],
    "detail-type" : [
      "AWS Console Sign In via CloudTrail"
    ],
    "detail" : {
      "eventSource" : [
        "route53.amazonaws.com"
      ],
      "eventName" : [
        "CreateHostedZone"
      ]
    }
  })
}

# Target for the eu-west-2 Event rule to invoke the Lambda function
resource "aws_cloudwatch_event_target" "lambda_function_in_eu" {
  rule = aws_cloudwatch_event_rule.route53_create_hosted_zone_eu.name
  arn  = aws_lambda_function.route53_notifier.arn
}
