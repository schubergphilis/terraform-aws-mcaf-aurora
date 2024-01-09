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

// Multi-AZ DB clusters are not the same as Aurora DB clusters. For information about Aurora DB clusters, see the Amazon Aurora User Guide.
// https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html
module "aurora" {
  source = "../.."

  name                          = "example"
  allocated_storage             = 100
  db_cluster_instance_class     = "db.r6gd.xlarge"
  engine                        = "mysql"
  instance_count                = 3
  iops                          = 1000
  kms_key_id                    = module.kms.arn
  master_user_secret_kms_key_id = module.kms.arn
  storage_type                  = "io1"
  subnet_ids                    = module.vpc.private_subnets

  security_group_ingress_rules = [
    {
      cidr_ipv4   = local.vpc_cidr
      description = "Allow access from the VPC CIDR range"
    }
  ]
}
