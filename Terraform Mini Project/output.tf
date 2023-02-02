# Load balancer details
output "lb_tg_arn" {
  value = aws_lb_target_group.alb-target-grp.arn
}

output "lb_dns_name" {
  value = aws_lb.applicationlb.dns_name
}

output "lb_zone_id" {
  value = aws_lb.applicationlb.zone_id
}