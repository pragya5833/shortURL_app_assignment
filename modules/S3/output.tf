output "frontend_domain" {
  value=aws_s3_bucket.primary_frontend.bucket_regional_domain_name
}
output "landing_domain" {
  value=aws_s3_bucket.primary_landing.bucket_regional_domain_name
}
output "frontend_domain_failover" {
  value=aws_s3_bucket.failover_frontend.bucket_regional_domain_name
}
output "landing_domain_failover" {
  value=aws_s3_bucket.failover_landing.bucket_regional_domain_name
}