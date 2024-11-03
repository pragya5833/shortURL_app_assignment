locals {
  common_tags={
    env="production"
    application="shorturl"
  }
}
locals {
  public_subnet_ids = [for s in aws_subnet.public_subnets : s.id if s != null]
  private_subnet_ids = [for s in aws_subnet.private_subnets : s.id if s != null]
}