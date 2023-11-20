resource "aws_lambda_function" "start" {
  function_name    = "environment-start"
  runtime          = "python3.9"
  handler          = "start_stop.lambda_handler"
  role             = aws_iam_role.start.arn
  filename         = data.archive_file.start_stop.output_path
  source_code_hash = data.archive_file.start_stop.output_base64sha256
  timeout          = 600
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
          "rds:DescribeDBInstances",
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

resource "aws_iam_role_policy_attachment" "basic_execution_start" {
  role       = aws_iam_role.start.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
