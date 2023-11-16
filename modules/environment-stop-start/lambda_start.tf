resource "aws_lambda_function" "rds_start_function" {
  function_name = "EnvironmentStartFunction"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_start_role.arn
  filename      = "${path.module}/lambdas/start_stop_rds.zip"
}

resource "aws_iam_role" "lambda_start_role" {
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

resource "aws_iam_role_policy" "lambda_start_policy" {
  name = "lambda-start-policy"
  role = aws_iam_role.lambda_start_role.id
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
