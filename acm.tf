resource "aws_acm_certificate" "wildcard_cert" {
  domain_name               = "mysuperdomain.com"
  validation_method         = "DNS"
  subject_alternative_names = ["*.skie.io"]
}
