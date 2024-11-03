data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
# Retrieve the EKS cluster details, including OIDC issuer URL
data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
