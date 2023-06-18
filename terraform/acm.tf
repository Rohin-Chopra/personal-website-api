resource "aws_acm_certificate" "api_certificate" {
  domain_name       = "api.rohinchopra.com"
  validation_method = "DNS"

  provider = aws.n_virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_certificate_validation" {
  certificate_arn         = aws_acm_certificate.api_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation_dns_record : record.fqdn]

  provider = aws.n_virginia
}
