# Explanation: CloudFront is the only public doorway — Chewbacca stands behind it with private infrastructure.
resource "aws_cloudfront_distribution" "chewbacca_cf01" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_name}-cf01"

  # --- 1. Origin Configuration (The "Secret Handshake") ---
  origin {
    origin_id   = "${var.project_name}-alb-origin01"
    domain_name = aws_lb.chewbacca_alb01.dns_name

    custom_origin_config {
      http_port  = 80
      https_port = 443
      # If we still get 502s, change this to "http-only" temporarily.
      # For now, we try to be secure:
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-Chewbacca-Growl"
      value = random_password.chewbacca_origin_header_value01.result
    }
  }

  # --- 2. Aliases & Certificates ---
  aliases = [
    var.domain_name,
    "${var.app_subdomain}.${var.domain_name}"
  ]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.chewbacca_cf_validation01.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # --- 3. Default Behavior (API Safety - Deliverable A2) ---
  # Explanation: Default behavior is conservative—Chewbacca assumes dynamic until proven static.
  default_cache_behavior {
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = aws_cloudfront_cache_policy.chewbacca_cache_api_disabled01.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.chewbacca_orp_api01.id
  }

  # --- 4. Ordered Behavior (Static Aggressive - Deliverable A3) ---
  # Explanation: Static behavior is the speed lane—Chewbacca caches it hard for performance.
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "${var.project_name}-alb-origin01"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = aws_cloudfront_cache_policy.chewbacca_cache_static01.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.chewbacca_orp_static01.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.chewbacca_rsp_static01.id
  }

  # --- 5. WAF & Geo ---
  web_acl_id = aws_wafv2_web_acl.chewbacca_waf01[0].arn

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}