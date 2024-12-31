locals {
  vpc_cidr = "10.0.0.0/16"

  azs_primary   = slice(data.aws_availability_zones.available_primary.names, 0, 3)
  azs_secondary = slice(data.aws_availability_zones.available_secondary.names, 0, 3)
}

# Primary region
data "aws_availability_zones" "available_primary" {}

provider "aws" {
  alias  = "primary"
  region = "eu-west-1"
}

module "vpc_primary" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name             = "example"
  azs              = local.azs_primary
  cidr             = local.vpc_cidr
  database_subnets = [for k, v in local.azs_primary : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  private_subnets  = [for k, v in local.azs_primary : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  public_subnets   = [for k, v in local.azs_primary : cidrsubnet(local.vpc_cidr, 8, k)]
}

resource "random_string" "master_password" {
  length  = 16
  special = false
}

module "aurora_primary" {
  providers = {
    aws = aws.primary
  }

  source = "../.."

  name                    = "example"
  engine                  = "postgresql"
  engine_mode             = "serverlessv2"
  engine_version          = "16.4"
  global_database_primary = true
  instance_count          = 2 # 1 Writer, 1 Reader
  master_password         = random_string.master_password.result
  subnet_ids              = module.vpc_primary.private_subnets

  security_group_ingress_rules = [
    {
      cidr_ipv4   = local.vpc_cidr
      description = "Allow access from the VPC CIDR range"
    }
  ]
}

# Secondary region
provider "aws" {
  alias  = "secondary"
  region = "eu-central-1"
}

data "aws_availability_zones" "available_secondary" {}

module "vpc_secondary" {
  providers = {
    aws = aws.secondary
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name             = "example"
  azs              = local.azs_secondary
  cidr             = local.vpc_cidr
  database_subnets = [for k, v in local.azs_secondary : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  private_subnets  = [for k, v in local.azs_secondary : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  public_subnets   = [for k, v in local.azs_secondary : cidrsubnet(local.vpc_cidr, 8, k)]
}

module "aurora_secondary" {
  providers = {
    aws = aws.secondary
  }

  source = "../.."

  name           = "example"
  engine         = "postgresql"
  engine_mode    = "serverlessv2"
  engine_version = "16.4"
  instance_count = 1 # 1 Reader
  subnet_ids     = module.vpc_secondary.private_subnets

  global_database_secondary = {
    global_cluster_identifier = module.aurora_primary.global_cluster_identifier
  }

  security_group_ingress_rules = [
    {
      cidr_ipv4   = local.vpc_cidr
      description = "Allow access from the VPC CIDR range"
    }
  ]
}
