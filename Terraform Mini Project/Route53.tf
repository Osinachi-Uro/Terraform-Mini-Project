#Create Hosted Zone
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

#Create a Resource Record
resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "terraform-test.${var.domain_name}"
  type    = "A"
 
  alias {
    name                   = aws_lb.applicationlb.dns_name
    zone_id                = aws_lb.applicationlb.zone_id
    evaluate_target_health = true
  }
}
