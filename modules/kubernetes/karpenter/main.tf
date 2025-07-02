terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
  }
}

resource "aws_sqs_queue" "karpenter_queue" {
  name                      = var.cluster_name
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue_policy" "karpenter_queue_policy" {
  queue_url = aws_sqs_queue.karpenter_queue.url
  policy    = data.aws_iam_policy_document.karpenter_iam_policy_document.json
}

resource "aws_cloudwatch_event_rule" "karpenter_cloudwatch_event_rule" {
  for_each = { for k, v in local.events : k => v }

  name_prefix   = "karpenter-${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "karpenter_cloudwatch_event_target" {
  for_each = { for k, v in local.events : k => v }

  rule      = aws_cloudwatch_event_rule.karpenter_cloudwatch_event_rule[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.karpenter_queue.arn
}

resource "helm_release" "karpenter_crd" {
  provider = helm

  namespace        = "karpenter"
  create_namespace = false

  cleanup_on_fail = true

  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = "1.4.0"

  lint = true
}

resource "helm_release" "karpenter" {
  provider         = helm
  namespace        = "karpenter"
  create_namespace = false

  depends_on = [
    helm_release.karpenter_crd
  ]

  cleanup_on_fail = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.4.0"

  lint = true

  set {
    name  = "controller.image.repository"
    value = "${var.aws_ecr_registry}/karpenter/controller"
  }

  set {
    name  = "controller.image.digest"
    value = "sha256:0b4527fc5c6bdf2e10c82ebb806a46f1c85b32ee080830ee59e5ea3993b1e6c3"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${var.aws_account}:role/${var.cluster_name}-karpenter"
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = var.instance_profile_name
  }

  set {
    name  = "settings.interruptionQueue"
    value = var.cluster_name
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "settings.featureGates.spotToSpotConsolidation"
    value = "true"
  }

}
