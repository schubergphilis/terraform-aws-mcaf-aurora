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
  password       = "password"
  subnet_ids     = module.vpc.private_subnets

  cluster_endpoints = {
    reader = {
      type           = "READER"
      static_members = ["example-3"] //"${var.name}-${instances key}"
    }
  }

  instance_config = {
    2 = { promotion_tier = 10 }
    3 = { promotion_tier = 20, instance_class = "db.t3.medium" }
  }
}
