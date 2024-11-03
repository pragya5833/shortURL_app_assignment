module "vpc" {
  source = "../../modules/vpc"
  cidr_range=var.vpc_cidr
  public_nacl_rules=var.public_nacl_rules
  private_nacl_rules=var.private_nacl_rules
  available_zones = data.aws_availability_zones.available.names
  supported_azs=local.supported_azs
}
module "ec2" {
  source = "../../modules/EC2"
  public_subnet_id=module.vpc.public_subnet[0]
  vpc_id=module.vpc.vpc_id
  allowed_cidrs=var.allowed_cidrs
  cluster_name = var.cluster_name
}
module "eks" {
  source = "../../modules/EKS"
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
  private_subnet_id=module.vpc.private_subnet
  node_group_name = var.node_group_name
  bastion_sg=module.ec2.bastion_sg
  bastion_role=module.ec2.bastion_role
  # bastion_sg=data.terraform_remote_state.bastion.outputs.bastion_sg
  # bastion_role=mdata.terraform_remote_state.bastion.outputs.bastion_role
  admin_role_arn=module.iam.admin_role_arn
  dev_role_arn=module.iam.dev_role_arn
  lb_security_group_id=module.alb.lb_security_group_id

}
module "iam" {
  source = "../../modules/IAM"
  issuer_url=module.eks.issuer_url
  cluster_name=var.cluster_name
  oidc_provider=module.eks.oidc_provider
  
}
module "alb" {
  source = "../../modules/ALB"
  vpc_id=module.vpc.vpc_id
  public_subnet_ids=module.vpc.public_subnet
  acm_certificate_arn=var.acm_certificate_arn
  route53_zone_id=var.route53_zone_id
  # node_ids=module.eks.node_ids
  # node_group=module.eks.node_group
  cluster_name=var.cluster_name
  node_group_name=var.node_group_name
  host_headers=var.host_headers
}
module "ecr" {
  source = "../../modules/ECR"
  ecr_repo_details=var.ecr_repo_details
  # repository_name=var.repository_name
  # image_tag_mutability=var.image_tag_mutability
  # push_on_scan=var.push_on_scan
}
module "rds" {
  source = "../../modules/RDS"
  vpc_id= module.vpc.vpc_id
  subnets_private=module.vpc.private_subnet
  db_password=local.db_credentials["password"]
  instance_class=var.instance_class
  engine_version=var.engine_version
  engine=var.engine
  identifier=var.identifier
  db_name=var.db_name
  allocated_storage=var.allocated_storage
  storage_type=var.storage_type
  multi_az=var.multi_az
  publicly_accessible=var.publicly_accessible
  skip_final_snapshot=var.skip_final_snapshot
  username=local.db_credentials["username"]
  db_subnet_group=var.db_subnet_group
  db_sg=var.db_sg
}