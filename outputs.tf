output "lb_zone_id" {
  value = module.alb.this_lb_zone_id
}

output "lb_dns_name" {
  value = module.alb.this_lb_dns_name
}

output "lb_arn" {
  value = module.alb.this_lb_arn
}

output "lb_id" {
  value = module.alb.this_lb_id
}

output "sg_id" {
  value = aws_security_group.alb.id
}

output "sg_arn" {
  value = aws_security_group.alb.arn
}

output "route53_record_id" {
  value = aws_route53_record.common.id
}
