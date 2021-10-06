# Terraform AWS Common ALB

This is a Terraform module which implements a commonly used pattern to create
AWS Application Load Balancers inside a VPC.

Minimum configuration
```hcl
module "shared_alb" {
  source  = "truemark/common-alb/aws"
  certificate_arn = module.infrastructure.private_cert_arn
  name = "my-shared-alb"
  subnets = module.infrastructure.private_subnet_ids
  vpc_id = module.infrastructure.vpc_id
}
```

Using a Route53 zone by ID
```hcl
module "shared_alb" {
  source  = "truemark/common-alb/aws"
  certificate_arn = module.infrastructure.private_cert_arn
  name = "my-shared-alb"
  subnets = module.infrastructure.private_subnet_ids
  vpc_id = module.infrastructure.vpc_id
  zone_id = module.infrastructure.private_zone_id
}
```

Using a private Route53 zone by name
```hcl
module "shared_alb" {
  source  = "truemark/common-alb/aws"
  certificate_arn = module.infrastructure.private_cert_arn
  name = "my-shared-alb"
  subnets = module.infrastructure.private_subnet_ids
  vpc_id = module.infrastructure.vpc_id
  zone_name = module.infrastructure.private_zone_name
  private_zone = true  
}
```

