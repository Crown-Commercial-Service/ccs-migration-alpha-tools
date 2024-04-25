#module "audit_log_group" {
#  source         = "../../resource-groups/cloudwatch-log-group"
#  log_group_name = var.log_group_name_audit_logs
#}

module "error_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_error_logs
}

module "index_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_index_slow_logs
}

module "search_slow_log_group" {
  source         = "../../resource-groups/cloudwatch-log-group"
  log_group_name = var.log_group_name_search_slow_logs
}

data "aws_iam_policy_document" "opensearch-log-publishing-policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogStream",
    ]

    resources = [
      "${module.error_log_group.log_group_arn}:*",
      "${module.index_slow_log_group.log_group_arn}:*",
      "${module.search_slow_log_group.log_group_arn}:*",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [
      "${module.error_log_group.log_group_arn}:log-stream:*",
      "${module.index_slow_log_group.log_group_arn}:log-stream:*",
      "${module.search_slow_log_group.log_group_arn}:log-stream:*",
    ]
  }  
}

resource "aws_cloudwatch_log_resource_policy" "opensearch-log-publishing-policy" {
  policy_name     = "opensearch-log-publishing-policy"
  policy_document = data.aws_iam_policy_document.opensearch-log-publishing-policy.json
}