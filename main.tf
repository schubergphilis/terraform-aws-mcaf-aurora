locals {
  skip_final_snapshot = var.final_snapshot_identifier == null
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

################################################################################
# Cluster
################################################################################

resource "aws_rds_cluster" "default" {
  #checkov:skip=CKV2_AWS_8: Ensuring that RDS clusters have an AWS Backup backup plan is not the responsibility of this module
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  cluster_identifier                  = var.stack
  copy_tags_to_snapshot               = true
  database_name                       = var.database
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.name
  db_subnet_group_name                = aws_db_subnet_group.default.name
  deletion_protection                 = var.deletion_protection
  enable_http_endpoint                = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  engine                              = var.engine
  engine_mode                         = var.engine_mode == "serverlessv2" ? "provisioned" : var.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  kms_key_id                          = var.kms_key_id
  master_password                     = var.password
  master_username                     = var.username
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = local.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted #tfsec:ignore:AWS051
  tags                                = var.tags
  vpc_security_group_ids              = [aws_security_group.default.id]

  dynamic "scaling_configuration" {
    for_each = var.engine_mode == "serverless" ? { create : null } : {}
    content {
      auto_pause               = var.auto_pause
      max_capacity             = var.max_capacity
      min_capacity             = var.min_capacity
      seconds_until_auto_pause = 1800
      timeout_action           = var.timeout_action
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.engine_mode == "serverlessv2" ? { create : null } : {}
    content {
      max_capacity = var.max_capacity
      min_capacity = var.min_capacity
    }
  }
}

################################################################################
# Cluster Instance(s)
################################################################################

resource "aws_rds_cluster_instance" "cluster_instances" {
  count = var.engine_mode == "serverless" ? 0 : var.instance_count

  apply_immediately                     = var.apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  cluster_identifier                    = aws_rds_cluster.default.id
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name                  = aws_db_subnet_group.default.name
  engine                                = var.engine
  engine_version                        = var.engine_version
  identifier                            = "${var.stack}-${count.index}"
  instance_class                        = var.engine_mode == "serverlessv2" ? "db.serverless" : var.instance_class
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled          = var.performance_insights
  performance_insights_kms_key_id       = var.performance_insights ? var.kms_key_id : null
  performance_insights_retention_period = var.performance_insights ? var.performance_insights_retention_period : null
  publicly_accessible                   = var.publicly_accessible
  tags                                  = var.tags
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "default" {
  name       = var.stack
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

################################################################################
# Enhanced Monitoring
################################################################################

module "rds_enhanced_monitoring_role" {
  count = var.monitoring_interval != null ? 1 : 0

  name                  = "RDSEnhancedMonitoringRole-${var.stack}"
  permissions_boundary  = var.permissions_boundary
  policy_arns           = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  postfix               = false
  principal_identifiers = ["monitoring.rds.amazonaws.com"]
  principal_type        = "Service"
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.3"
  tags                  = var.tags
}

################################################################################
# Parameter Group - Cluster
################################################################################

resource "aws_rds_cluster_parameter_group" "default" {
  name        = var.stack
  description = "RDS default cluster parameter group"
  family      = var.cluster_family
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

################################################################################
# Parameter Group - DB
################################################################################

resource "aws_db_parameter_group" "default" {
  count = var.database_parameters != null ? 1 : 0

  description = "RDS default database parameter group"
  family      = var.cluster_family
  name        = "${var.stack}-aurora"
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.database_parameters

    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "default" {
  name        = "${var.stack}-aurora"
  description = "Access to Aurora"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count = var.cidr_blocks != null ? 1 : 0

  cidr_blocks       = var.cidr_blocks
  description       = "Aurora ingress"
  from_port         = aws_rds_cluster.default.port
  protocol          = "tcp"
  security_group_id = aws_security_group.default.id
  to_port           = aws_rds_cluster.default.port
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_groups" {
  count = length(var.security_group_ids)

  description              = "Aurora ingress"
  from_port                = aws_rds_cluster.default.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default.id
  source_security_group_id = var.security_group_ids[count.index]
  to_port                  = aws_rds_cluster.default.port
  type                     = "ingress"
}
