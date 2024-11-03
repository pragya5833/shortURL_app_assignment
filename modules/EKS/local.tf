locals {
  auth_cm_data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_nodegroup_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = var.bastion_role
        username = "bastion"
        groups   = ["system:masters"]
      }
    ])
  }
}
locals {
  issuer_url=replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
}

