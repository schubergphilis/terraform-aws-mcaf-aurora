data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_security_group" "default" {
  name        = "${var.stack}-aurora"
  description = "Access to Aurora"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count             = var.cidr_blocks != null ? 1 : 0
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  description       = "Aurora ingress"
  from_port         = aws_rds_cluster.default.port
  to_port           = aws_rds_cluster.default.port
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "ingress_groups" {
  count                    = length(var.security_group_ids)
  security_group_id        = aws_security_group.default.id
  type                     = "ingress"
  description              = "Aurora ingress"
  from_port                = aws_rds_cluster.default.port
  to_port                  = aws_rds_cluster.default.port
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[count.index]
}

resource "aws_db_subnet_group" "default" {
  name       = var.stack
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = var.stack
  description = "RDS default cluster parameter group"
  family      = var.cluster_family
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "aws_rds_db_parameter_group" "default" {
  name        = var.stack
  description = "RDS default database parameter group"
  family      = var.cluster_family
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.database_parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier                  = var.stack
  database_name                       = var.database
  master_username                     = var.username
  master_password                     = var.password
  enable_http_endpoint                = var.enable_http_endpoint
  engine                              = var.engine
  engine_version                      = var.engine_version
  engine_mode                         = var.engine_mode
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  db_subnet_group_name                = aws_db_subnet_group.default.name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.name
  deletion_protection                 = var.deletion_protection
  final_snapshot_identifier           = var.final_snapshot_identifier
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  vpc_security_group_ids              = [aws_security_group.default.id]
  tags                                = var.tags
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  dynamic "scaling_configuration" {
    for_each = var.engine_mode == "serverless" ? { create : null } : {}
    content {
      auto_pause               = var.auto_pause
      max_capacity             = var.max_capacity
      min_capacity             = var.min_capacity
      seconds_until_auto_pause = 1800
    }
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = var.engine_mode == "serverless" ? 0 : var.instance_count
  apply_immediately               = var.apply_immediately
  cluster_identifier              = aws_rds_cluster.default.id
  db_subnet_group_name            = aws_db_subnet_group.default.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  identifier                      = "${var.stack}-${count.index}"
  instance_class                  = var.instance_class
  publicly_accessible             = var.publicly_accessible
  db_parameter_group_name         = aws_rds_db_parameter_group.default.name
  performance_insights_enabled    = var.performance_insights
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  monitoring_interval             = var.monitoring_interval
}
