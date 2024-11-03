output "public_subnet_ids" {
  value = module.vpc.public_subnet
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_ip" {
  value = module.ec2.public_ip
}
# output "bastion_public_key" {
#   value = module.ec2.bastion_public_key
#   sensitive = false
# }
output "eks_cluster_endpoint" {
  value = module.eks.eks_endpoint
}
output "eks_cluster_certificate_authority" {
  value = module.eks.eks_cluster_certificate_authority
}
output "eks_cluster_token" {
  value = module.eks.eks_cluster_token
  sensitive = true
}
output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}
# Use the parsed values
output "db_username" {
  value     = local.db_credentials["username"]
  sensitive = true
}

output "db_password" {
  value     = local.db_credentials["password"]
  sensitive = true
}