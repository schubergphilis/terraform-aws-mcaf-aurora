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

// Multi-AZ DB clusters are not the same as Aurora DB clusters. For information about Aurora DB clusters, see the Amazon Aurora User Guide.
// https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html
module "aurora" {
  source = "../.."

  name                      = "example"
  allocated_storage         = 100
  allowed_cidr_blocks       = [local.vpc_cidr]
  db_cluster_instance_class = "db.r6gd.xlarge"
  instance_count            = 3
  iops                      = 1000
  storage_type              = "io1"
  subnet_ids                = module.vpc.private_subnets
}
