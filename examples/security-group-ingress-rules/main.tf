locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr = "10.0.0.0/16"
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name             = "example"
  azs              = local.azs
  cidr             = local.vpc_cidr
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
}

module "kms" {
  source = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.3.0"
  name   = "example"
}

module "aurora" {
  source = "../.."

  name                          = "example"
  instance_class                = "db.r6g.large"
  kms_key_id                    = module.kms.arn
  master_user_secret_kms_key_id = module.kms.arn
  subnet_ids                    = module.vpc.private_subnets

  security_group_ingress_rules = [
    {
      cidr_ipv4   = "1.1.1.1/32"
      description = "Allow access from an IP range"
    },
    {
      referenced_security_group_id = "sg-02ce123456e7893c7"
      description                  = "Allow access from another security group"
    }
  ]
}
