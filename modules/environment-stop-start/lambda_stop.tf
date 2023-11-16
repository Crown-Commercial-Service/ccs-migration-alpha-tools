resource "aws_lambda_function" "stop" {
  function_name = "EnvironmentStop"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.stop.arn
  filename      = "${path.module}/lambdas/start_stop_rds.zip"
}

resource "aws_iam_role" "stop" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role_policy" "stopy" {
  name = "lambda-stop-policy"
  role = aws_iam_role.stop.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:StopDBInstance",
          "ecs:UpdateService"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
