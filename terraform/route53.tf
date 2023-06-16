data "aws_route53_zone" "primary_zone" {
  name         = "rohinchopra.com"
  private_zone = false
}

resource "aws_route53_record" "domain_validation_dns_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.primary_zone.zone_id
}

resource "aws_route53_record" "api_record" {
  name    = "api.rohinchopra.com"
  type    = "A"
  zone_id = data.aws_route53_zone.primary_zone.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api_domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain_name.regional_zone_id
    evaluate_target_health = false
  }
}
