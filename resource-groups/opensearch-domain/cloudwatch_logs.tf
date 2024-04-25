module "search_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_search_slow_logs
}

module "index_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_index_slow_logs
}

module "error_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_error_logs
}

module "audit_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_audit_logs
}

data "aws_iam_policy_document" "opensearch_cloudwatch_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_cloudwatch_policy" {
  policy_name     = "opensearch_cloudwatch_policy"
  policy_document = data.aws_iam_policy_document.opensearch_cloudwatch_policy.json
}