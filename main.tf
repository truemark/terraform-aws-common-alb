resource "aws_security_group" "alb" {
  name        = var.name
  description = "Controls access to ALB ${var.name}"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = var.name
  })
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
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 8.0"
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal
  idle_timeout       = var.idle_timeout

  access_logs            = {
    bucket = module.log_bucket[0].s3_bucket_id
    prefix = "${var.name}-access_logs"
  }

  enable_xff_client_port = var.enable_xff_client_port
  target_groups          = []

  subnets = var.subnets
  vpc_id  = var.vpc_id

  create_security_group = false
  security_groups = [aws_security_group.alb.id]

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

  access_logs            = {
    bucket = module.log_bucket[0].s3_bucket_id
    prefix = "${var.name}-access_logs"
  }

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

module "log_bucket" {
  count   = var.create_logs ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = var.bucket_name
  acl           = "log-delivery-write"

  # For example only
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true
      expiration = {
        days = var.expiration_days
        }
    }
  ]

  tags = var.tags
}
