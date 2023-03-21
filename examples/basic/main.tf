locals {
  create_db = true
}

resource "random_password" "master_password" {
  count = local.create_db ? 1 : 0

  length  = "20"
  special = false
}

module "aurora" {
  count  = local.create_db ? 1 : 0
  source = "../../"

  cidr_blocks                         = ["1.1.1.1/24"]
  cluster_family                      = "aurora-mysql8.0"
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  engine                              = "aurora-mysql"
  engine_mode                         = "provisioned"
  engine_version                      = "8.0.mysql_aurora.3.02.2"
  iam_database_authentication_enabled = true
  instance_class                      = "db.t3.medium"
  instance_count                      = 1
  password                            = random_password.master_password[0].result
  stack                               = "example"
  subnet_ids                          = ["subnet-00000000000000000", "subnet-00000000000000001"]
  username                            = "admin_user"

  tags = {
    env = "production"
  }
}
