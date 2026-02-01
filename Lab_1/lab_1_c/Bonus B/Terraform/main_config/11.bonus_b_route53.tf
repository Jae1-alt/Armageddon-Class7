# Instead of creating a zone, we look up the existing one by ID
data "aws_route53_zone" "selected" {
  zone_id = var.route53_hosted_zone_id
}

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

# Points the domain to the AWS resource-ALB
resource "aws_route53_record" "chewbacca_app_dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.chewbacca_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.chewbacca_alb01.dns_name
    zone_id                = aws_lb.chewbacca_alb01.zone_id
    evaluate_target_health = true
  }
}

