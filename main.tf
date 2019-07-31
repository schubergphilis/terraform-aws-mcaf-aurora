locals {
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : aws_subnet.public[*].id
  vpc_id     = data.aws_subnet.selected.vpc_id
}

data aws_subnet selected {
  id = local.subnet_ids[0]
}

resource aws_security_group default {
  name        = "${var.stack}-aurora"
  description = "Access to Aurora"
  vpc_id      = local.vpc_id
  tags        = var.tags

  ingress {
    description = "All inbound traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
    self        = true
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_db_subnet_group default {
  name       = var.stack
  subnet_ids = local.subnet_ids
  tags       = var.tags
}

resource aws_rds_cluster_parameter_group default {
  name        = var.stack
  description = "RDS default cluster parameter group"
  family      = "aurora5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource aws_rds_cluster default {
  cluster_identifier              = var.stack
  database_name                   = var.database
  master_username                 = var.username
  master_password                 = var.password
  engine                          = "aurora"
  engine_version                  = "5.6.10a"
  engine_mode                     = "serverless"
  iam_roles                       = var.iam_roles
  apply_immediately               = var.apply_immediately
  db_subnet_group_name            = aws_db_subnet_group.default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  deletion_protection             = var.deletion_protection
  final_snapshot_identifier       = var.final_snapshot_identifier
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  vpc_security_group_ids          = [aws_security_group.default.id]
  tags                            = var.tags

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = 1800
    timeout_action           = "ForceApplyCapacityChange"
  }

  lifecycle {
    create_before_destroy = true
  }
}
