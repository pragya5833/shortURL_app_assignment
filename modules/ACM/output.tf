output "frontend_cert" {
  value = aws_acm_certificate.cert_frontend.arn
}
output "landing_cert" {
  value = aws_acm_certificate.cert_landing.arn
}