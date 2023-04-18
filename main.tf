locals {
  instance_class      = var.engine_mode == "serverlessv2" ? "db.serverless" : var.instance_class
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
  cluster_identifier                  = var.name
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
  manage_master_user_password         = var.manage_master_user_password ? var.manage_master_user_password : null
  master_password                     = var.master_password
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  master_username                     = var.master_username
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
# Cluster Endpoint(s)
################################################################################

resource "aws_rds_cluster_endpoint" "default" {
  for_each = { for identifier, settings in var.endpoints : identifier => settings if var.engine_mode != "serverless" }

  cluster_endpoint_identifier = lower(each.key)
  cluster_identifier          = aws_rds_cluster.default.id
  custom_endpoint_type        = each.value.type
  excluded_members            = length(var.endpoints.reader.excluded_members) == 0 ? null : [for member in each.value.excluded_members : "${var.name}-${member}"]
  static_members              = length(var.endpoints.reader.static_members) == 0 ? null : [for member in each.value.static_members : "${var.name}-${member}"]
  tags                        = var.tags

  depends_on = [
    aws_rds_cluster.default
  ]
}

################################################################################
# Cluster Instance(s)
################################################################################

/*
Because Terraform uses parallelism by default, using 1 resource with a loop results in downtime when modifying certain variables.
therefore a main cluster instance resource is created and additional cluster instance resources when applicable to ensure 1 instance is always available.
*/
resource "aws_rds_cluster_instance" "first" {
  count = var.engine_mode == "serverless" ? 0 : 1

  apply_immediately                     = var.apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  cluster_identifier                    = aws_rds_cluster.default.id
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name                  = aws_db_subnet_group.default.name
  engine                                = var.engine
  engine_version                        = var.engine_version
  identifier                            = "${var.name}-${count.index + 1}"
  instance_class                        = try(var.instance_config[count.index + 1]["instance_class"], null) != null ? var.instance_config[count.index + 1]["instance_class"] : local.instance_class
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled          = var.performance_insights
  performance_insights_kms_key_id       = var.performance_insights ? var.kms_key_id : null
  performance_insights_retention_period = var.performance_insights ? var.performance_insights_retention_period : null
  promotion_tier                        = try(var.instance_config[count.index + 1]["promotion_tier"], null)
  publicly_accessible                   = var.publicly_accessible
  tags                                  = var.tags
}

resource "aws_rds_cluster_instance" "rest" {
  count = var.engine_mode == "serverless" ? 0 : var.instance_count - 1

  apply_immediately                     = var.apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  cluster_identifier                    = aws_rds_cluster.default.id
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name                  = aws_db_subnet_group.default.name
  engine                                = var.engine
  engine_version                        = var.engine_version
  identifier                            = "${var.name}-${count.index + 2}"
  instance_class                        = try(var.instance_config[count.index + 2]["instance_class"], null) != null ? var.instance_config[count.index + 2]["instance_class"] : local.instance_class
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled          = var.performance_insights
  performance_insights_kms_key_id       = var.performance_insights ? var.kms_key_id : null
  performance_insights_retention_period = var.performance_insights ? var.performance_insights_retention_period : null
  promotion_tier                        = try(var.instance_config[count.index + 2]["promotion_tier"], null)
  publicly_accessible                   = var.publicly_accessible
  tags                                  = var.tags

  depends_on = [
    aws_rds_cluster_instance.first
  ]
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "default" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

################################################################################
# Enhanced Monitoring
################################################################################

module "rds_enhanced_monitoring_role" {
  count = var.monitoring_interval != null ? 1 : 0

  name                  = "RDSEnhancedMonitoringRole-${var.name}"
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
  name        = var.name
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

  name        = "${var.name}-aurora"
  description = "RDS default database parameter group"
  family      = var.cluster_family
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
  name        = "${var.name}-aurora"
  description = "Access to Aurora"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count = var.allowed_cidr_blocks != null ? 1 : 0

  cidr_blocks       = var.allowed_cidr_blocks
  description       = "Aurora ingress"
  from_port         = aws_rds_cluster.default.port
  protocol          = "tcp"
  security_group_id = aws_security_group.default.id
  to_port           = aws_rds_cluster.default.port
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_groups" {
  for_each = toset(var.allowed_security_group_ids)

  description              = "Aurora ingress"
  from_port                = aws_rds_cluster.default.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default.id
  source_security_group_id = each.value
  to_port                  = aws_rds_cluster.default.port
  type                     = "ingress"
}
