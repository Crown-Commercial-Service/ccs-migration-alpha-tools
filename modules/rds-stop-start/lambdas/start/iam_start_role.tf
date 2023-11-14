resource "aws_lambda_function" "rds_start_function" {
  function_name = "RDSStopFunction"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.rds_lambda_role.arn
  filename      = "modules/rds-stop-start/lambdas/start_stop_rds.py"
}

resource "aws_iam_role" "lambda_start_role" {
  assume_role_policy = jsondecode({
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
  role = aws_iam_role.rds_lambda_role.id
  policy = jsondecode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:StartDBInstance"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
