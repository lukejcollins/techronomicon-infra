# Create an AWS Route 53 Zone for the domain "lukecollins.dev"
resource "aws_route53_zone" "my_domain" {
  count = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  name  = var.DOMAIN_NAME
}

# Create a Route 53 record for the domain "lukecollins.dev"
resource "aws_route53_record" "my_domain_a" {
  count   = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  zone_id = aws_route53_zone.my_domain[0].zone_id
  name    = var.DOMAIN_NAME
  type    = "A"
  ttl     = 300
  records = [aws_instance.example.public_ip]
}

# Create a Route 53 record for the subdomain "preprod.lukecollins.dev"
resource "aws_route53_record" "preprod_subdomain_a" {
  count   = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  zone_id = aws_route53_zone.my_domain[0].zone_id
  name    = "preprod.${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = 300
  records = [var.PREPROD_IP_ADDRESS]
}

# MX Records
resource "aws_route53_record" "my_domain_mx" {
  count   = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  zone_id = aws_route53_zone.my_domain[0].zone_id
  name    = var.DOMAIN_NAME
  type    = "MX"
  ttl     = 300
  records = [
    "10 mx01.mail.icloud.com.",
    "10 mx02.mail.icloud.com."
  ]
}

# TXT Record
resource "aws_route53_record" "my_domain_txt_apple" {
  count   = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  zone_id = aws_route53_zone.my_domain[0].zone_id
  name    = var.DOMAIN_NAME
  type    = "TXT"
  ttl     = 300
  records = [
    "apple-domain=NRN6vsl89kvt10mT",
    "v=spf1 include:icloud.com ~all"
  ]
}

# DKIM Record
resource "aws_route53_record" "my_domain_dkim" {
  count   = var.ROUTE_53_RESOURCES_BOOL ? 1 : 0
  zone_id = aws_route53_zone.my_domain[0].zone_id
  name    = "sig1._domainkey.${var.DOMAIN_NAME}"
  type    = "CNAME"
  ttl     = 300
  records = ["sig1.dkim.lukecollins.dev.at.icloudmailadadmin.com."]
}
