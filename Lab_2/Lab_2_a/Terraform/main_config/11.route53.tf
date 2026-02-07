# Instead of creating a zone, we look up the existing one by ID
data "aws_route53_zone" "selected" {
  zone_id = var.route53_hosted_zone_id
}

########################################################################
# New Route53 Record association for ALB
########################################################################
# 2. The Certificate Request
resource "aws_acm_certificate" "chewbacca_acm_cert01" {
  domain_name       = "${var.app_subdomain}.${var.domain_name}"
  validation_method = "DNS"

  subject_alternative_names = [var.domain_name]

  lifecycle {
    create_before_destroy = true
  }
}

# Validation Records: Pointing specifically to the 'selected' zone ID
resource "aws_route53_record" "chewbacca_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.chewbacca_acm_cert01.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id # Using pre-existing Zone ID
}

resource "aws_acm_certificate_validation" "chewbacca_acm_validation01" {
  certificate_arn         = aws_acm_certificate.chewbacca_acm_cert01.arn
  validation_record_fqdns = [for r in aws_route53_record.chewbacca_acm_validation : r.fqdn]
}

########################################################################
# New Route53 Record association for CloudFront Distribution
########################################################################
# Explanation: DNS now points to CloudFront — nobody should ever see the ALB again.
resource "aws_route53_record" "chewbacca_apex_to_cf01" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.chewbacca_cf01.domain_name
    zone_id                = aws_cloudfront_distribution.chewbacca_cf01.hosted_zone_id
    evaluate_target_health = false
  }
}

# Explanation: app.chewbacca-growl.com also points to CloudFront — same doorway, different sign.
resource "aws_route53_record" "chewbacca_app_to_cf01" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.app_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.chewbacca_cf01.domain_name
    zone_id                = aws_cloudfront_distribution.chewbacca_cf01.hosted_zone_id
    evaluate_target_health = false
  }
}

########################################################################
# Route 53 Record and ACM for Cloudfront Distribution US-EAST-1 region
########################################################################

resource "aws_acm_certificate" "chewbacca_cf_cert01" {
  provider = aws.us_e_1

  domain_name               = "${var.app_subdomain}.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name]

  lifecycle { create_before_destroy = true }
}

# DNS Validation for the CloudFront Cert
resource "aws_route53_record" "chewbacca_cf_validation" {
  for_each = {
    for dvo in aws_acm_certificate.chewbacca_cf_cert01.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# Wait for the CloudFront Cert to be Valid
resource "aws_acm_certificate_validation" "chewbacca_cf_validation01" {
  provider                = aws.us_e_1
  
  certificate_arn         = aws_acm_certificate.chewbacca_cf_cert01.arn
  validation_record_fqdns = [for r in aws_route53_record.chewbacca_cf_validation : r.fqdn]
}
