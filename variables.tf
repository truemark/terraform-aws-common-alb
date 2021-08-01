variable "name" {}

variable "certificate_arn" {}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
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

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
