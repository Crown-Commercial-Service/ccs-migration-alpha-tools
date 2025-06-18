data "aws_kms_key" "eks" {
  key_id = "alias/aws/eks"
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}