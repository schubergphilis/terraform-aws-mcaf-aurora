variable "allocated_storage" {
  type        = number
  default     = null
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (Required for Multi-AZ DB cluster)"
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable to allow major engine version upgrades when changing engine versions"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Specifies whether any cluster modifications are applied immediately"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window`"
}

variable "auto_pause" {
  type        = bool
  default     = true
  description = "Whether to enable automatic pause"
}

variable "backtrack_window" {
  type        = number
  default     = 0
  description = "The target backtrack window, in seconds. Only available for `mysql` engines. Must be between 0 (disabled) and 259200 (72 hours)"

  validation {
    condition     = var.backtrack_window >= 0 && var.backtrack_window <= 259200
    error_message = "Value must be between \"0\" and \"259200\" (72 hours)"
  }
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain backups for"
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "Identifier of the CA certificate for the DB instance"


  validation {
    condition     = var.ca_cert_identifier != null ? contains(["rds-ca-2019", "rds-ca-rsa2048-g1", "rds-ca-rsa4096-g1", "rds-ca-ecc384-g1"], var.ca_cert_identifier) : true
    error_message = "Allowed values for ca_cert_identifier are \"rds-ca-2019\", \"rds-ca-rsa2048-g1\", \"rds-ca-rsa4096-g1\", \"rds-ca-ecc384-g1\"."
  }
}

variable "cluster_family" {
  type        = string
  default     = null
  description = "The family of the DB cluster parameter group"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = optional(string, "immediate")
    name         = string
    value        = string
  }))
  default = [{
    name         = "character_set_server",
    value        = "utf8",
    apply_method = "pending-reboot"
    }, {
    name         = "character_set_client",
    value        = "utf8",
    apply_method = "pending-reboot"
    }, {
    name         = "require_secure_transport",
    value        = "ON",
    apply_method = "immediate"
  }]
  description = "A list of cluster DB parameters to apply"
}

variable "database" {
  type        = string
  default     = null
  description = "The name of the first database to be created when the cluster is created"

  validation {
    condition     = (var.global_database_secondary != null && var.database == null) || var.global_database_secondary == null
    error_message = "Cannot specify database name for global secondary cluster"
  }
}

variable "database_parameters" {
  type = list(object({
    apply_method = optional(string, "immediate")
    name         = string
    value        = string
  }))
  default     = null
  description = "A list of instance DB parameters to apply"
}

variable "db_cluster_instance_class" {
  type        = string
  default     = null
  description = "The compute and memory capacity of each DB instance in the Multi-AZ DB cluster. Only set this variable if you are deploying a Multi-AZ DB cluster. (Required for Multi-AZ DB cluster)"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "A boolean indicating if the DB instance should have deletion protection enable"
}

variable "enable_cloudwatch_logs_exports" {
  type        = bool
  default     = true
  description = "Set to false to disable logging to cloudwatch"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = null
  description = "List of log types to export to cloudwatch, by default all supported types are exported"
}

variable "enable_http_endpoint" {
  type        = bool
  default     = false
  description = "Enable Aurora Serverless HTTP endpoint (Data API)"
}

variable "endpoints" {
  type = map(object({
    excluded_members = optional(list(string), [])
    static_members   = optional(list(string), [])
    type             = string
  }))
  default     = {}
  description = "A map of additional cluster endpoints to be created"
}

variable "engine" {
  type        = string
  description = "The engine type of the Aurora cluster"

  validation {
    condition     = contains(["mysql", "postgresql"], var.engine)
    error_message = "Allowed values for engine are \"mysql\", \"postgresql\""
  }
}

variable "engine_mode" {
  type        = string
  default     = "provisioned"
  description = "The engine mode of the Aurora cluster"

  validation {
    condition     = contains(["provisioned", "serverless", "parallelquery", "global", "multimaster", "serverlessv2"], var.engine_mode)
    error_message = "Allowed values for engine_mode are \"provisioned\", \"serverless\", \"parallelquery\", \"global\", \"multimaster\" or \"serverlessv2\"."
  }
}

variable "engine_version" {
  type        = string
  default     = null
  description = "The engine version of the Aurora cluster"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Identifier of the final snapshot to create before deleting the cluster"
}

variable "global_database_primary" {
  type        = bool
  default     = false
  description = "Whether the cluster is part of a global database as the primary cluster"
}

variable "global_database_secondary" {
  type = object({
    global_cluster_identifier      = string
    enable_global_write_forwarding = optional(bool, true)
  })
  default     = null
  description = "Whether the cluster is part of a global database as the seconday cluster"

  validation {
    condition     = !(var.global_database_primary && var.global_database_secondary != null)
    error_message = "Cannot configure a cluster as both primary and secondary in a global database"
  }
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = true
  description = "Specify if mapping AWS IAM accounts to database accounts is enabled."
}

variable "iam_roles" {
  type        = list(string)
  default     = null
  description = "A list of IAM Role ARNs to associate with the cluster"
}

variable "instance_class" {
  type        = string
  default     = null
  description = "The class of RDS instances to attach to the cluster instances (not used when `engine_mode` set to `serverless`)"
}

variable "instance_config" {
  type = map(object({
    instance_class = optional(string, null)
    promotion_tier = optional(number, null)
  }))
  default     = null
  description = "Map of instance specific settings that override values set elsewhere in the module, map keys should match instance number"
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "The number of RDS instances to attach (not used when `engine_mode` set to `serverless`)"
}

variable "iops" {
  type        = number
  default     = null
  description = "The amount of Provisioned IOPS to be initially allocated for each DB instance. (Required for Multi-AZ DB cluster)"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "ARN of KMS key to encrypt storage and performance insights data"
}

variable "manage_master_user" {
  type        = bool
  default     = true
  description = "Set to false to provide a custom password using `master_password`"

  validation {
    condition     = var.global_database_primary == false || (var.global_database_primary && var.manage_master_user == false)
    error_message = "Cannot enable manage_master_user for a global database"
  }
}

variable "master_password" {
  type        = string
  default     = null
  description = "Password for the master DB user, must set `manage_master_user` to false if specifying a custom password"

  validation {
    condition     = (var.global_database_secondary != null && var.master_password == null) || var.global_database_secondary == null
    error_message = "Cannot specify master_password for global secondary cluster"
  }
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "ID of KMS key to encrypt the master user Secrets Manager secret"
}

variable "master_username" {
  type        = string
  default     = null
  description = "Username for the master DB user"

  validation {
    condition     = (var.global_database_secondary != null && var.master_username == null) || var.global_database_secondary == null
    error_message = "Cannot specify master_username for global secondary cluster"
  }
}

variable "max_capacity" {
  type        = number
  default     = 8
  description = "The maximum capacity of the serverless cluster"
}

variable "min_capacity" {
  type        = number
  default     = 1
  description = "The minimum capacity of the serverless cluster"
}

variable "monitoring_interval" {
  type        = string
  default     = null
  description = "The interval (seconds) for collecting enhanced monitoring metrics"
}

variable "name" {
  type        = string
  description = "The name for the Aurora Cluster"
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "The name for the DB / RDS cluster parameter groups"
}

variable "performance_insights" {
  type        = bool
  default     = true
  description = "Specifies whether Performance Insights is enabled or not"
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Amount of time in days to retain Performance Insights data, must be `7`, `731` (2 years) or a multiple of `31`"

  validation {
    condition     = var.performance_insights_retention_period == 7 || var.performance_insights_retention_period == 731 || var.performance_insights_retention_period % 31 == 0
    error_message = "Value must be \"7\", \"731\" (2 years) or a multiple of \"31\""
  }
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "The ARN of the policy that is used to set the permissions boundary for the role"
}

variable "preferred_backup_window" {
  type        = string
  default     = null
  description = "The daily time range during which automated backups are created, in UTC e.g. 04:00-09:00"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = null
  description = "The weekly time range during which system maintenance can occur, in UTC e.g. wed:04:00-wed:04:30"
}

variable "publicly_accessible" {
  type        = string
  default     = false
  description = "Control if instances in cluster are publicly accessible"
}

variable "security_group_ingress_rules" {
  type = list(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = string
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default     = []
  description = "Security Group ingress rules"

  validation {
    condition     = alltrue([for o in var.security_group_ingress_rules : (o.cidr_ipv4 != null || o.cidr_ipv6 != null || o.prefix_list_id != null || o.referenced_security_group_id != null)])
    error_message = "One of \"cidr_ipv4\", \"cidr_ipv6\", \"prefix_list_id\", or \"referenced_security_group_id\" must be provided in order to allow ingress connectivity"
  }
}

variable "seconds_until_auto_pause" {
  type        = number
  default     = 1800
  description = "The time, in seconds, before an Aurora Serverless DB cluster is paused"

  validation {
    condition     = var.seconds_until_auto_pause >= 300 && var.seconds_until_auto_pause <= 86400
    error_message = "seconds_until_auto_pause must be between 300 (5 minutes) and 86400 (1 day)"
  }
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "Database snapshot identifier to create the database from"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DB cluster is encrypted"
}

variable "storage_type" {
  type        = string
  default     = null
  description = "Specifies the storage type to be associated with the DB cluster. (Required for Multi-AZ DB cluster)`"

  validation {
    condition     = var.storage_type != null ? contains(["io1", "aurora-iopt1", ""], var.storage_type) : true
    error_message = "Allowed values for storage_type are \"io1\", \"aurora-iopt1\"."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy Aurora in"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A mapping of tags to assign to the bucket"
}

variable "timeout_action" {
  type        = string
  default     = "RollbackCapacityChange"
  description = "The action to take when the timeout is reached"

  validation {
    condition     = contains(["ForceApplyCapacityChange", "RollbackCapacityChange"], var.timeout_action)
    error_message = "Allowed values for timeout_action are \"ForceApplyCapacityChange\", \"RollbackCapacityChange\"."
  }
}
