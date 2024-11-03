module "s3" {
  source = "../../modules/S3"
  primary_bucket_name_frontend=var.primary_bucket_name_frontend
  failover_bucket_name_frontend=var.failover_bucket_name_frontend
  primary_bucket_name_landing=var.primary_bucket_name_landing
  failover_bucket_name_landing=var.failover_bucket_name_landing
  oai_id = module.cloudfront.origin_access_identity
}
module "cloudfront" {
  source = "../../modules/Cloudfront"
  primary_bucket_name_frontend=module.s3.frontend_domain
  failover_bucket_name_frontend=module.s3.frontend_domain_failover
  primary_bucket_name_landing=module.s3.landing_domain
  failover_bucket_name_landing=module.s3.landing_domain_failover
  frontend_cert=module.acm.frontend_cert
  landing_cert=module.acm.landing_cert
}
module "acm" {
  source = "../../modules/ACM"
#   zone_id = var.zone_id
}
module "r53" {
    source = "../../modules/R53"
  frontend_domain=module.cloudfront.frontend_domain
  landing_domain=module.cloudfront.landing_domain
  frontend_zone_id = var.frontend_zone_id
  landing_zone_id=var.landing_zone_id
}