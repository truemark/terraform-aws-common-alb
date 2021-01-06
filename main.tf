module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = var.name
  load_balancer_type = "application"

  access_logs = {}
  target_groups = []

  subnets = var.subnets

  https_listeners = [
    {
      port = 443
      protocol = "HTTPS"
      certificate_arn = var.certificate_arn
      ssl_policy = var.ssl_policy
      target_group_arn = null
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "ok"
        status_code = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port = 80
      protocol = "HTTP"
      action_type = "redirect"
      redirect = {
        port = "443"
        protocol = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

data "aws_route53_zone" "common" {
  count = contains(["", null], var.zone_name) ? 0 : 1
  name = var.zone_name
}

resource "aws_route53_record" "common" {
  count = contains(["", null], var.zone_name) ? 0 : 1
  name = var.name
  type = "A"
  zone_id = data.aws_route53_zone.common[count.index].zone_id
  alias {
    name = module.alb.this_lb_dns_name
    zone_id = module.alb.this_lb_zone_id
    evaluate_target_health = false
  }
}
