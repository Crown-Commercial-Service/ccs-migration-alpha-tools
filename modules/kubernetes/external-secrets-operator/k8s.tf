resource "kubernetes_namespace" "external_secrets_operator_namespace" {
  metadata {
    name = var.external_secrets_operator_namespace
  }
}

resource "kubernetes_service_account" "external_secrets_service_account" {
  metadata {
    name      = var.external_secrets_service_account
    namespace = var.external_secrets_operator_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
    }
  }
}