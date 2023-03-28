locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr = "10.0.0.0/16"
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

resource "random_password" "root_password" {
  length  = "20"
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name             = "example"
  azs              = local.azs
  cidr             = local.vpc_cidr
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
}

module "aurora" {
  source = "../.."

  name           = "example"
  engine_mode    = "provisioned"
  instance_count = 3
  password       = random_password.root_password.result
  subnet_ids     = module.vpc.private_subnets

  endpoints = {
    reader = {
      type           = "READER"
      static_members = [3]
    }
  }

  instance_config = {
    2 = { promotion_tier = 10 }
    3 = { promotion_tier = 20, instance_class = "db.t3.medium" }
  }

  security_group_rules = {
    ingress_allowed_cidr_blocks = [local.vpc_cidr]
  }
}
