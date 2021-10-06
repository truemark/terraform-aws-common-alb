output "lb_zone_id" {
  description = "The Availability Zones for the Application Load Balancer."
  value = module.alb.lb_zone_id
}

output "lb_dns_name" {
  description = "The DNS name for the Application Load Balancer."
  value = module.alb.lb_dns_name
}

output "lb_arn" {
  description = "The ARN of the Application Load Balancer."
  value = module.alb.lb_arn
}

output "lb_id" {
  description = "The id of the Application Load Balancer."
  value = module.alb.lb_id
}

output "sg_id" {
  description = "The Security Group ID of the Application Load Balancer."
  value = aws_security_group.alb.id
}

output "sg_arn" {
  description = "The Security Groups ARN that the Application Load Balancer is to reside within."
  value = aws_security_group.alb.arn
}

output "route53_record_id" {
  description = "The Route53 records for the Application Load Balancer."
  value = join("", aws_route53_record.alb.*.id)
}
