resource "aws_eks_cluster" "this" {
  name     = "eks-${var.project}"
  role_arn = aws_iam_role.eks_cluster_iam_role.arn
  version  = var.k8s_version

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  vpc_config {
    endpoint_private_access = true
    public_access_cidrs     = var.public_cidr_allowlist
    subnet_ids              = [for i, v in var.private_subnets : v.id]
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "eks-${var.project}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_iam_role.arn
  subnet_ids      = [for i, v in var.private_subnets : v.id]
  capacity_type   = var.capacity_type
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }
}

resource "aws_security_group" "this" {
  name        = "eks-${var.project}-node-security-group"
  description = "Security group for the worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    "karpenter.sh/discovery" = "eks-${var.project}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_https" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 31443
  ip_protocol       = "tcp"
  to_port           = 31443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 31080
  ip_protocol       = "tcp"
  to_port           = 31080
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
}

resource "aws_ec2_tag" "karpenter_sg_discovery" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.this.name
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"

}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
}

