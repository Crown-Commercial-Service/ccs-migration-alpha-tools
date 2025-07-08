locals {
  oidc_issuer_url    = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  oidc_provider_host = replace(local.oidc_issuer_url, "https://", "")
  oidc_provider_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_host}"
}