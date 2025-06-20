terraform {
  required_providers {
    kubernetes = {}
  }
}

resource "kubernetes_config_map" "this" {
  depends_on = [
    aws_eks_cluster.this
  ]

  data = {
    mapRoles = replace(
      replace(
        yamlencode(
          distinct(
        concat(local.node_roles, var.additional_iam_roles))),
      "@AWS_ACCOUNT@", data.aws_caller_identity.current.account_id),
      "\"", ""
    )
    mapUsers = replace(
      replace(
        yamlencode(var.additional_iam_users),
      "@AWS_ACCOUNT@", data.aws_caller_identity.current.account_id),
      "\"", ""
    )
    mapAccounts = yamlencode(var.additional_aws_accounts)
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}