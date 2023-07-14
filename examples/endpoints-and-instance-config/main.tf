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

module "aurora" {
  source = "../.."

  name                = "example"
  allowed_cidr_blocks = [local.vpc_cidr]
  instance_class      = "db.r6g.large"
  instance_count      = 3
  subnet_ids          = module.vpc.private_subnets

  endpoints = {
    reader = {
      type           = "READER"
      static_members = [3]
    }
  }

  instance_config = {
    2 = { promotion_tier = 10 }
    3 = { promotion_tier = 15, instance_class = "db.t3.medium" }
  }
}
