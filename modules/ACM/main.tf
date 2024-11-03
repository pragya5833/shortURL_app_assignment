resource "aws_acm_certificate" "cert_frontend" {
  domain_name       = "*.frontend.deeplink.in"  # Ensure this matches the primary domain in AWS
  validation_method = "DNS"                  # Check if the validation method matches

  subject_alternative_names = ["frontend.deeplink.in"]  # Ensure SANs exactly match those in AWS


 lifecycle {
    prevent_destroy = true
  }
}

resource "aws_acm_certificate" "cert_landing" {
  domain_name       = "deeplink.in"
  validation_method = "DNS"

  subject_alternative_names = ["*.deeplink.in"]

  lifecycle {
    prevent_destroy = true
  }
}



