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

resource "aws_rds_cluster" "default" {
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  cluster_identifier                  = var.stack
  database_name                       = var.database
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.name
  db_subnet_group_name                = aws_db_subnet_group.default.name
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  enable_http_endpoint                = var.enable_http_endpoint
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  kms_key_id                          = var.kms_key_id #tfsec:ignore:AWS051
  master_password                     = var.password
  master_username                     = var.username
  skip_final_snapshot                 = var.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  tags                                = var.tags
  vpc_security_group_ids              = [aws_security_group.default.id]

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

resource "aws_db_parameter_group" "default" {
  count       = var.database_parameters != null ? 1 : 0
  name        = "${var.stack}-aurora"
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

module "rds_enhanced_monitoring_role" {
  count                 = var.monitoring_interval != null ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.0"
  name                  = "RDSEnhancedMonitoringRole-${var.stack}"
  principal_type        = "Service"
  principal_identifiers = ["monitoring.rds.amazonaws.com"]
  policy_arns           = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  postfix               = false
  tags                  = var.tags
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = var.engine_mode == "serverless" ? 0 : var.instance_count
  apply_immediately               = var.apply_immediately
  cluster_identifier              = aws_rds_cluster.default.id
  db_parameter_group_name         = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name            = aws_db_subnet_group.default.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  identifier                      = "${var.stack}-${count.index}"
  instance_class                  = var.instance_class
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled    = var.performance_insights
  performance_insights_kms_key_id = var.kms_key_id
  publicly_accessible             = var.publicly_accessible
}
