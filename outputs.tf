output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = " The IDs of the load balancer listeners created."
  value       = module.alb.https_listener_ids
}

output "lb_zone_id" {
  description = "The Availability Zones for the Application Load Balancer."
  value       = module.alb.lb_zone_id
}

output "lb_dns_name" {
  description = "The DNS name for the Application Load Balancer."
  value       = module.alb.lb_dns_name
}

output "lb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = module.alb.lb_arn
}

output "lb_id" {
  description = "The id of the Application Load Balancer."
  value       = module.alb.lb_id
}

output "sg_id" {
  description = "The Security Group ID of the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "sg_arn" {
  description = "The Security Groups ARN that the Application Load Balancer is to reside within."
  value       = aws_security_group.alb.arn
}

output "route53_record_id" {
  description = "The Route53 records for the Application Load Balancer."
  value       = join("", aws_route53_record.alb.*.id)
}

output "nlb_dns_name" {
  value = join("", module.nlb.*.lb_dns_name)
}

output "nlb_zone_id" {
  value = join("", module.nlb.*.lb_zone_id)
}

output "nlb_arn" {
  value = join("", module.nlb.*.lb_arn)
}

output "nlb_id" {
  value = join("", module.nlb.*.lb_id)
}

output "nlb_api_gateway_vpc_link_arn" {
  value = join("", aws_api_gateway_vpc_link.nlb.*.arn)
}

output "nlb_api_gateway_vpc_link_id" {
  value = join("", aws_api_gateway_vpc_link.nlb.*.id)
}

output "nlb_api_gateway_vpc_link_name" {
  value = join("", aws_api_gateway_vpc_link.nlb.*.name)
}
