resource "aws_opensearch_domain" "domain" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  cluster_config {
    instance_count         = var.instance_count
    instance_type          = var.instance_type
    zone_awareness_enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size_gib
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    security_group_ids = [aws_security_group.opensearch.id]
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    # Needed for Terraform to set up VPC endpoints at apply time, hence specific dependency
    aws_iam_service_linked_role.opensearch
  ]

  lifecycle {
    ignore_changes = [
      # Workaround for https://github.com/hashicorp/terraform-provider-aws/issues/27371
      advanced_options["override_main_response_version"]
    ]
  }

  # Options to enable CloudWatch logging. Audit logs commented out due to need to 
  # enable "advanced security options", i.e. fine-grained access control

  #log_publishing_options {
  #  enabled = var.enable_audit_logs
  #  cloudwatch_log_group_arn = module.audit_log_group.log_group_arn
  #  log_type = "AUDIT_LOGS"
  #}

  log_publishing_options {
    enabled = var.enable_error_logs
    cloudwatch_log_group_arn = module.error_log_group.log_group_arn
    log_type = "ES_APPLICATION_LOGS"
  }
  
  log_publishing_options {
    enabled = var.enable_index_slow_logs
    cloudwatch_log_group_arn = module.index_slow_log_group.log_group_arn
    log_type = "INDEX_SLOW_LOGS"
  }
  
  log_publishing_options {
    enabled = var.enable_search_slow_logs
    cloudwatch_log_group_arn = module.search_slow_log_group.log_group_arn
    log_type = "SEARCH_SLOW_LOGS"
  }
  
  tags = {
    Domain = var.domain_name
  }
}

resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

data "aws_iam_policy_document" "domain_resource_based" {
  statement {
    sid = "AllowOpensearchHttpActions"

    effect = "Allow"

    principals {
      type = "AWS"
      # Access is limited by VPC Security Group
      identifiers = [
        "*"
      ]
    }

    actions   = ["es:*"]
    resources = ["${aws_opensearch_domain.domain.arn}/*"]
  }
  
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.domain.domain_name
  access_policies = data.aws_iam_policy_document.domain_resource_based.json
}

resource "aws_security_group" "opensearch" {
  name        = "${var.resource_name_prefixes.normal}:${var.domain_name}:OPENSEARCH"
  description = "${var.domain_name} OpenSearch"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.domain_name}-opensearch"
  }
}

resource "aws_security_group" "opensearch_clients" {
  name        = "${var.resource_name_prefixes.normal}:${var.domain_name}:OPENSEARCH:CLIENTS"
  description = "Entities permitted to access the ${var.domain_name} OpenSearch domain"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.domain_name}-opensearch-clients"
  }
}

resource "aws_security_group_rule" "opensearch_https_in" {
  security_group_id = aws_security_group.opensearch.id
  description       = "Allow HTTPS inwards from opensearch-clients SG"

  from_port                = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.opensearch_clients.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "opensearch_clients_https_out" {
  security_group_id = aws_security_group.opensearch_clients.id
  description       = "Allow HTTPS outwards from group member to OpenSearch VPC endpoint"

  from_port                = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.opensearch.id
  to_port                  = 443
  type                     = "egress"
}
