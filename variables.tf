variable "name" {
  description = ""
}

variable "certificate_arn" {
  description = "The ARN of the Certificate for the Application Load Balancer."
}

variable "ssl_policy" {
  description = "The SSL-Policy ID for the Application Load Balancer. Defaults to: ELBSecurityPolicy-FS-1-2-Res-2020-10."
  default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "zone_name" {
  description = "The Route53 Zone Name for the Application Load Balancer. Leave empty to skip creating a route53 record for the ALB. Defualt is '' (empty)."
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

variable "vpc_id" {
  description = "The ID of the VPC that the Application Load Balancer is to reside within."
}

variable "subnets" {
  description = "A list of Subnets of the Application Load Balancers. Subnets can be from your Availability Zones, a Local Zone, or an Outpost. If its an AZ, each subnet must be from a different Availability Zone. For Outpost subnets, See AWS Outposts guide."
  type = list(string)
}

variable "ingress_cidrs" {
  description = "A list of inbounding (ingressing) CIDRS (e.g. 0.0.0.0/0, ::/0)."
  default = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  type = string
  default = false
}
