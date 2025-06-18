output "ca" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}
output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "oidc_provider" {
  value = {
    url               = aws_eks_cluster.this.identity[0].oidc[0].issuer
    url_sans_protocol = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  }
}