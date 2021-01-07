resource "aws_security_group" "alb" {
  name = var.name
  description = "Controls access to ALB ${var.name}"
  vpc_id = var.vpc_id
  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidrs
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidrs
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = var.name
  load_balancer_type = "application"

  access_logs = {}
  target_groups = []

  subnets = var.subnets

  security_groups = [aws_security_group.alb.id]

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
