# data "aws_eks_node_group" "node_groups" {
#   for_each = var.node_groups

#   cluster_name    = var.cluster_name
#   node_group_name = each.value.node_group_name
# }
# Retrieve the worker node security group using tags
data "aws_security_group" "worker_node_sg" {
  filter {
    name   = "tag:kubernetes.io/cluster/${var.cluster_name}"
    values = ["owned"]
  }

  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["${var.cluster_name}"]  # Replace "acme_corp" with your cluster's name
  }
}
data "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
}
