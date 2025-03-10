locals {
  instance_class      = var.engine_mode == "serverlessv2" ? "db.serverless" : var.instance_class
  skip_final_snapshot = var.final_snapshot_identifier == null

  global_cluster_identifier = var.global_database_primary ? aws_rds_global_cluster.default[0].id : var.global_database_secondary != null ? var.global_database_secondary.global_cluster_identifier : null

  // For a secondary cluster, the KMS key must be specified explicitly even if defaulted to the AWS Managed alias ("For encrypted cross-region replica, kmsKeyId should be explicitly specified").
  kms_key_arn = var.global_database_secondary != null && var.storage_encrypted && var.kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_key_id

  // Backtrack is only supported for MySQL clusters
  backtrack_window = {
    "mysql"      = var.backtrack_window
    "postgresql" = null
  }[var.engine]

  // Default cluster family to use unless otherwise specified
  cluster_family = var.cluster_family != null ? var.cluster_family : {
    "mysql"      = "aurora-mysql8.0"
    "postgresql" = "aurora-postgresql15"
  }[var.engine]

  // Default set of logs to export to CloudWatch unless otherwise specified
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports != null ? var.enabled_cloudwatch_logs_exports : {
    "mysql"      = ["audit", "error", "general", "slowquery"]
    "postgresql" = ["postgresql"]
  }[var.engine]

  // Default master username to use unless otherwise specified
  master_username = var.master_username != null || var.global_database_secondary != null ? var.master_username : {
    "mysql"      = "root"
    "postgresql" = "postgres"
  }[var.engine]
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

################################################################################
# Global Database
################################################################################

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

resource "aws_rds_global_cluster" "default" {
  count = var.global_database_primary ? 1 : 0

  global_cluster_identifier = "${var.name}-global"
  engine                    = "aurora-${var.engine}"
  engine_version            = var.engine_version
  database_name             = var.database
  storage_encrypted         = var.storage_encrypted
  tags                      = var.tags
}

################################################################################
# Cluster
################################################################################

resource "aws_rds_cluster" "default" {
  #checkov:skip=CKV2_AWS_8: Ensuring that RDS clusters have an AWS Backup backup plan is not the responsibility of this module
  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  backtrack_window                    = local.backtrack_window
  cluster_identifier                  = var.name
  copy_tags_to_snapshot               = true
  database_name                       = var.database
  db_cluster_parameter_group_name     = try(aws_rds_cluster_parameter_group.default[0].name, null)
  db_subnet_group_name                = aws_db_subnet_group.default.name
  db_cluster_instance_class           = var.db_cluster_instance_class
  deletion_protection                 = var.deletion_protection
  enable_http_endpoint                = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports     = var.enable_cloudwatch_logs_exports ? local.enabled_cloudwatch_logs_exports : null
  enable_global_write_forwarding      = var.global_database_secondary != null ? var.global_database_secondary.enable_global_write_forwarding : null
  engine                              = "aurora-${var.engine}"
  engine_mode                         = var.engine_mode == "serverlessv2" ? "provisioned" : var.engine_mode
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  global_cluster_identifier           = local.global_cluster_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  iops                                = var.iops
  kms_key_id                          = local.kms_key_arn
  manage_master_user_password         = var.manage_master_user ? var.manage_master_user : null
  master_password                     = var.master_password
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id
  master_username                     = local.master_username
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = local.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted #tfsec:ignore:AWS051
  vpc_security_group_ids              = [aws_security_group.default.id]
  storage_type                        = var.storage_type
  tags                                = var.tags

  dynamic "scaling_configuration" {
    for_each = var.engine_mode == "serverless" ? { create : null } : {}

    content {
      auto_pause               = var.auto_pause
      max_capacity             = var.max_capacity
      min_capacity             = var.min_capacity
      seconds_until_auto_pause = var.seconds_until_auto_pause
      timeout_action           = var.timeout_action
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.engine_mode == "serverlessv2" ? { create : null } : {}

    content {
      max_capacity             = var.max_capacity
      min_capacity             = var.min_capacity
      seconds_until_auto_pause = var.min_capacity == 0 ? var.seconds_until_auto_pause : null
    }
  }

  lifecycle {
    ignore_changes = [replication_source_identifier]
  }
}

################################################################################
# Cluster Endpoint(s)
################################################################################

resource "aws_rds_cluster_endpoint" "default" {
  for_each = { for name, settings in var.endpoints : name => settings if var.engine_mode != "serverless" }

  cluster_endpoint_identifier = lower("${aws_rds_cluster.default.id}-${each.key}")
  cluster_identifier          = aws_rds_cluster.default.id
  custom_endpoint_type        = each.value.type
  excluded_members            = length(each.value.excluded_members) == 0 ? null : [for member in each.value.excluded_members : "${var.name}-${member}"]
  static_members              = length(each.value.static_members) == 0 ? null : [for member in each.value.static_members : "${var.name}-${member}"]
  tags                        = var.tags

  depends_on = [
    aws_rds_cluster_instance.first,
    aws_rds_cluster_instance.rest,
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
  ca_cert_identifier                    = var.ca_cert_identifier
  cluster_identifier                    = aws_rds_cluster.default.id
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name                  = aws_db_subnet_group.default.name
  engine                                = "aurora-${var.engine}"
  engine_version                        = var.engine_version
  identifier                            = "${var.name}-${count.index + 1}"
  instance_class                        = try(var.instance_config[count.index + 1]["instance_class"], null) != null ? var.instance_config[count.index + 1]["instance_class"] : local.instance_class
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled          = var.performance_insights
  performance_insights_kms_key_id       = var.performance_insights ? local.kms_key_arn : null
  performance_insights_retention_period = var.performance_insights ? var.performance_insights_retention_period : null
  promotion_tier                        = try(var.instance_config[count.index + 1]["promotion_tier"], null)
  publicly_accessible                   = var.publicly_accessible
  tags                                  = var.tags
}

resource "aws_rds_cluster_instance" "rest" {
  count = var.engine_mode == "serverless" ? 0 : var.instance_count - 1

  apply_immediately                     = var.apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  ca_cert_identifier                    = var.ca_cert_identifier
  cluster_identifier                    = aws_rds_cluster.default.id
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = try(aws_db_parameter_group.default[0].name, null)
  db_subnet_group_name                  = aws_db_subnet_group.default.name
  engine                                = "aurora-${var.engine}"
  engine_version                        = var.engine_version
  identifier                            = "${var.name}-${count.index + 2}"
  instance_class                        = try(var.instance_config[count.index + 2]["instance_class"], null) != null ? var.instance_config[count.index + 2]["instance_class"] : local.instance_class
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = try(module.rds_enhanced_monitoring_role[0].arn, null)
  performance_insights_enabled          = var.performance_insights
  performance_insights_kms_key_id       = var.performance_insights ? local.kms_key_arn : null
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

  source  = "schubergphilis/mcaf-role/aws"
  version = "~> 0.4.0"

  name                  = "RDSEnhancedMonitoringRole-${var.name}"
  permissions_boundary  = var.permissions_boundary
  policy_arns           = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  postfix               = false
  principal_identifiers = ["monitoring.rds.amazonaws.com"]
  principal_type        = "Service"
  tags                  = var.tags
}

################################################################################
# Parameter Group - Cluster
################################################################################

resource "aws_rds_cluster_parameter_group" "default" {
  count = var.cluster_parameters != null ? 1 : 0

  name        = coalesce(var.parameter_group_name, var.name)
  description = "RDS default cluster parameter group"
  family      = local.cluster_family
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Parameter Group - DB
################################################################################

resource "aws_db_parameter_group" "default" {
  count = var.database_parameters != null ? 1 : 0

  name        = coalesce(var.parameter_group_name, "${var.name}-aurora")
  description = "RDS default database parameter group"
  family      = local.cluster_family
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.database_parameters

    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
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

resource "aws_vpc_security_group_ingress_rule" "default" {
  for_each = length(var.security_group_ingress_rules) != 0 ? { for v in var.security_group_ingress_rules : v.description => v } : {}

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = aws_rds_cluster.default.port
  ip_protocol                  = "tcp"
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.default.id
  to_port                      = aws_rds_cluster.default.port
  tags                         = var.tags
}
