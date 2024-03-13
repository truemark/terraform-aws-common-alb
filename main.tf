module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 8.0"
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal
  idle_timeout       = var.idle_timeout

  access_logs            = var.access_logs
  enable_xff_client_port = var.enable_xff_client_port
  target_groups          = []

  subnets = var.subnets
  vpc_id  = var.vpc_id

  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = var.ingress_cidrs
    }
    ingress_all_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS web traffic"
      cidr_blocks = var.ingress_cidrs
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  https_listeners = [
    {
      port             = 443
      protocol         = "HTTPS"
      certificate_arn  = var.certificate_arn
      ssl_policy       = var.ssl_policy
      target_group_arn = null
      action_type      = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "ok"
        status_code  = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = var.tags
}

data "aws_route53_zone" "alb" {
  count        = var.zone_name == "" || var.zone_id != "" ? 0 : 1
  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "alb" {
  count   = var.zone_name == "" && var.zone_id == "" ? 0 : 1
  name    = var.name
  type    = "A"
  zone_id = var.zone_id != "" ? var.zone_id : data.aws_route53_zone.alb[count.index].zone_id
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
  }
}

module "nlb" {
  count              = var.create_nlb ? 1 : 0
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 8.0"
  name               = "${var.name}-nlb"
  load_balancer_type = "network"
  internal           = var.internal
  subnets            = var.subnets

  vpc_id = var.vpc_id

  access_logs = var.access_logs

  target_groups = [
    {
      name_prefix      = "http"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "alb"
      targets = [
        {
          target_id = module.alb.lb_id
          port      = 80
        }
      ]
    },
    {
      name_prefix      = "https"
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "alb"
      targets = [
        {
          target_id = module.alb.lb_id
          port      = 443
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 1
    }
  ]

  tags = var.tags
}

resource "aws_api_gateway_vpc_link" "nlb" {
  count       = var.create_nlb && var.create_nlb_api_gateway_vpc_link ? 1 : 0
  name        = "${var.name}-nlb"
  target_arns = [join("", module.nlb.*.lb_arn)]
}
