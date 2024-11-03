resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Shared OAI for multiple distributions"
}
resource "aws_cloudfront_distribution" "s3_distribution_frontend" {
  origin {
    domain_name = var.primary_bucket_name_frontend
    origin_id   = "S3-primary"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  origin {
    domain_name = var.failover_bucket_name_frontend
    origin_id   = "S3-secondary"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  origin_group {
    origin_id = "origin-group-s3"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "S3-primary"
    }

    member {
      origin_id = "S3-secondary"
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin-group-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true

    # lambda_function_association {
    #   event_type   = "origin-request"
    #   lambda_arn   = aws_lambda_function.redirect.arn
    # }
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }
  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }

  viewer_certificate {
    acm_certificate_arn = var.frontend_cert
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  aliases             = ["frontend.deeplink.in"]
}

resource "aws_cloudfront_distribution" "s3_distribution_landing" {
  origin {
    domain_name = var.primary_bucket_name_landing
    origin_id   = "S3-primary"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  origin {
    domain_name = var.failover_bucket_name_landing
    origin_id   = "S3-secondary"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  origin_group {
    origin_id = "origin-group-s3"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "S3-primary"
    }

    member {
      origin_id = "S3-secondary"
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin-group-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true

    # lambda_function_association {
    #   event_type   = "origin-request"
    #   lambda_arn   = aws_lambda_function.redirect.arn
    # }
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }
   custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }

  viewer_certificate {
    acm_certificate_arn = var.landing_cert
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  aliases             = ["deeplink.in"]
}

