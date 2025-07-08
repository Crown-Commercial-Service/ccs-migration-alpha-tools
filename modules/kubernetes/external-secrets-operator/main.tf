terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
  }
}

resource "helm_release" "external_secrets_operator" {
  provider      = helm
  name          = "external-secrets"
  chart         = "external-secrets"
  repository    = "https://charts.external-secrets.io"
  timeout       = 900
  namespace     = kubernetes_namespace.external_secrets_operator_namespace.metadata[0].name
  lint          = true
  recreate_pods = true

  set {
    name  = "fullnameOverride"
    value = "external-secrets"
  }

  set {
    name  = "image.pullPolicy"
    value = "IfNotPresent"
  }
}