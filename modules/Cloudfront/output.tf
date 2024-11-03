output "frontend_domain" {
  value = aws_cloudfront_distribution.s3_distribution_frontend.domain_name
}
output "landing_domain" {
  value = aws_cloudfront_distribution.s3_distribution_landing.domain_name
}
output "origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.oai.id
}