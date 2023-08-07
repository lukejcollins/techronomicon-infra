# Create an AWS Route 53 Zone for the domain "lukecollins.dev"
resource "aws_route53_zone" "my_domain" {
  name = var.DOMAIN_NAME
}

# Create a Route 53 record for the domain "lukecollins.dev"
resource "aws_route53_record" "my_domain_a" {
  zone_id = aws_route53_zone.my_domain.zone_id
  name    = var.DOMAIN_NAME
  type    = "A"
  ttl     = 300
  records = [aws_instance.example.public_ip]
}
