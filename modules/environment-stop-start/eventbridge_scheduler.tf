resource "aws_iam_role" "eventbridge_scheduler_role" {
  name = "eventbridge-scheduler-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : "sts:AssumeRole",
          Principal = {
            Service = "scheduler.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "allow-eventbridge-scheduler" {
  name = "allow-eventbridge-scheduler"
  role = aws_iam_role.eventbridge_scheduler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "scheduler:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_policy_attachment" {
  role       = aws_iam_role.eventbridge_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess"
}
