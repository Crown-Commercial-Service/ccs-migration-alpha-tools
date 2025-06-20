locals {
  node_roles = [
    {
      rolearn : aws_iam_role.eks_fargate.arn
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    },
    {
      rolearn : aws_iam_role.eks_node_group_iam_role.arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
    # {
    #   rolearn : var.karpenter_role_arn
    #   username : "system:node:{{EC2PrivateDNSName}}"
    #   groups : [
    #     "system:bootstrappers",
    #     "system:nodes"
    #   ]
    # }
  ]
}