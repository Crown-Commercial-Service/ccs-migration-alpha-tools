resource "aws_iam_role" "lambda_role" {
  name = "lambda_role_for_route53_notification"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy_for_route53_notification"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "events:DescribeEventBus",
          "events:DescribeEventSource",
          "events:DescribeRule",
          "events:ListEventBuses",
          "events:ListEventSources",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "sns:Publish",
          "route53:Get*",
          "route53:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ],
  })
}

resource "null_resource" "zip_lambda_function" {
  provisioner "local-exec" {
    command = "zip -j ${path.module}/lambda_function.zip ${path.module}/lambda_function.py"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

# The Lambda function
resource "aws_lambda_function" "route53_notifier" {
  filename      = "${path.module}/lambda_function.zip"
  function_name = "route53_notifier"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
}

# Grant EventBridge permissions to invoke the Lambda function
resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.route53_create_hosted_zone_eu.arn
}
