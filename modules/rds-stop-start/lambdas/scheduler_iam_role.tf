resource "aws_iam_role" "eventbridge_scheduler_role" {
  name = "eventbridge-scheduler-role"
  assume_role_policy = jsondecode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "scheduler:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:PassRole",
          "Resource" : "arn:aws:iam::*:role/*",
          "Condition" : {
            "StringLike" : {
              "iam:PassedToService" : "scheduler.amazonaws.com"
            }
          }
        },
        {
          "Sid" : "AllowLambdaFunction",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_policy_attachment" {
  role       = aws_iam_role.eventbridge_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess"
}
