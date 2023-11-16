resource "aws_lambda_function" "start" {
  function_name = "EnvironmentStartFunction"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.start.arn
  filename      = "${path.module}/lambdas/start_stop_rds.zip"
}

resource "aws_iam_role" "start" {
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

resource "aws_iam_role_policy" "start" {
  name = "lambda-start-policy"
  role = aws_iam_role.start.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:StartDBInstance",
          "ecs:UpdateService"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
