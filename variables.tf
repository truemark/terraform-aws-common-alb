variable "name" {}

variable "certificate_arn" {}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "zone_name" {
  description = "Leave empty to skip creating a route53 record for the ALB"
  default = ""
}

variable "private_zone" {
  description = "True if zone_name is a private zone, false if public"
  default = false
}

variable "zone_id" {
  description = "Leave empty to skip creating a route53 record for the ALB. This field overrides values placed in zone_name."
  default = ""
}

variable "vpc_id" {}

variable "subnets" {
  type = list(string)
}

variable "ingress_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
