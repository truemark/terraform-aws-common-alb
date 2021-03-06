variable "name" {}

variable "certificate_arn" {}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-2016-08"
}

variable "zone_name" {
  description = "Leave empty to skip creating a route53 record for the ALB"
  default = ""
}

variable "vpc_id" {}

variable "subnets" {
  type = list(string)
}

variable "ingress_cidrs" {
  default = ["0.0.0.0/0"]
}
