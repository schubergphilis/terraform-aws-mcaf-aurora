locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

resource "random_password" "master_password" {
  length  = "20"
  special = false
}

module "aurora" {
  source = "../../"

  cluster_family                      = "aurora-mysql8.0"
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  engine                              = "aurora-mysql"
  engine_mode                         = "provisioned"
  engine_version                      = "8.0.mysql_aurora.3.02.2"
  iam_database_authentication_enabled = true
  instance_class                      = "db.t3.medium"
  password                            = random_password.master_password.result
  security_group_rules                = { ingress_allowed_cidr_blocks = [local.vpc_cidr] }
  stack                               = "example"
  subnet_ids                          = module.vpc.private_subnets
  username                            = "admin_user"

  cluster_endpoints = {
    reader = {
      type           = "READER"
      static_members = ["example-3"] //"${var.stack}-${instances key}"
    }
  }

  instances = {
    1 = {}
    2 = {
      promotion_tier = 10,
    }
    3 = {
      promotion_tier = 15,
      instance_class = "db.t3.medium"
    }
  }

  tags = {
    env = "production"
  }
}

// Supporting Resources
module "vpc" {
  #checkov:skip=CKV_AWS_111 False positive
  #checkov:skip=CKV2_AWS_12: False positive
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                                 = "example"
  azs                                  = local.azs
  cidr                                 = "10.0.0.0/16"
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  database_subnets                     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  default_network_acl_name             = "example-default-nacl"
  default_security_group_egress        = []
  default_security_group_ingress       = []
  default_security_group_name          = "example-default-sg"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_flow_log                      = true
  manage_default_network_acl           = true
  manage_default_security_group        = true
  map_public_ip_on_launch              = false
  private_subnets                      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  public_subnets                       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  tags = {
    env = "production"
  }
}
