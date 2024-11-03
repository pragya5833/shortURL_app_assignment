resource "aws_route53_record" "frontend_alias" {
  zone_id = var.frontend_zone_id  // Your DNS zone ID
  name    = "frontend.deeplink.in"
  type    = "A"

  alias {
    name                   = var.frontend_domain
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
  
}

resource "aws_route53_record" "landing_alias" {
  zone_id = var.landing_zone_id
  name    = "deeplink.in"
  type    = "A"

  alias {
    name                   = var.landing_domain
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
  
}


