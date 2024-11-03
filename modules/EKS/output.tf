output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
output "eks_cluster_certificate_authority" {
 value=aws_eks_cluster.eks_cluster.certificate_authority[0].data 
}


output "eks_cluster_token" {
  value = data.aws_eks_cluster_auth.eks_cluster.token
  sensitive = true
}
output "issuer_url" {
  value=replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
}
output "oidc_provider" {
  value=aws_iam_openid_connect_provider.eks_oidc_provider.arn
}
# output "node_ids" {
#   value = aws_eks_node_group.eks_node_group.resources[*].instance_id
# }

# output "node_groups" {
#   value = {
#     for key, ng in aws_eks_node_group.eks_node_group :
#     key => {
#       node_group_name = ng.node_group_name
#       resources       = ng.resources
#     }
#   }
# }
# Output the node group details, including security group IDs
# output "node_group" {
#   value = {
#     node_group_name = aws_eks_node_group.eks_node_group.node_group_name
#     resources = [
#       {
#         autoscaling_groups  = [{ name = data.aws_autoscaling_group.node_group_asg[aws_eks_node_group.eks_node_group.node_group_name].name }]
#         security_group_ids  = data.aws_autoscaling_group.node_group_asg[aws_eks_node_group.eks_node_group.node_group_name].vpc_zone_identifier
#       }
#     ]
#   }
# }


