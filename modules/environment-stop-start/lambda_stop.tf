resource "aws_lambda_function" "stop" {
  function_name    = "environment-stop"
  runtime          = "python3.9"
  handler          = "start_stop.lambda_handler"
  role             = aws_iam_role.stop.arn
  filename         = data.archive_file.start_stop.output_path
  source_code_hash = data.archive_file.start_stop.output_base64sha256
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
          "ecs:UpdateService",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
