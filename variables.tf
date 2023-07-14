variable "allocated_storage" {
  type        = number
  default     = null
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (Required for Multi-AZ DB cluster)"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = null
  description = "List of CIDR blocks to add to the cluster security group that should be allowed access to the Aurora cluster"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to add to the cluster security group that should be allowed access to the Aurora cluster"
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
  default     = null
  description = "The target backtrack window, in seconds. Only available for `aurora` and `aurora-mysql` engines. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours)"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "The days to retain backups for"
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
  default     = "aurora-mysql8.0"
  description = "The family of the DB cluster parameter group"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = optional(string, "immediate")
    name         = string
    value        = string
  }))
  default = [{
    name  = "character_set_server",
    value = "utf8",
    }, {
    name  = "character_set_client",
    value = "utf8",
  }]
  description = "A list of cluster DB parameters to apply"
}

variable "database" {
  type        = string
  default     = null
  description = "The name of the first database to be created when the cluster is created"
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

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = null
  description = "List of log types to export to cloudwatch"
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
  default     = "aurora-mysql"
  description = "The engine type of the Aurora cluster"

  validation {
    condition     = contains(["aurora", "aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "Allowed values for engine are \"aurora\", \"aurora-mysql\", \"aurora-postgresql\""
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
  default     = "8.0.mysql_aurora.3.02.2"
  description = "The engine version of the Aurora cluster"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Identifier of the final snapshot to create before deleting the cluster"
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
  description = "ID of KMS key to encrypt storage and performance insights data"
}

variable "manage_master_user" {
  type        = bool
  default     = true
  description = "Set to false to provide a custom password using `master_password`"
}

variable "master_password" {
  type        = string
  default     = null
  description = "Password for the master DB user, must set `manage_master_user` to false if specifying a custom password"
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "ID of KMS key to encrypt the master user Secrets Manager secret"
}

variable "master_username" {
  type        = string
  default     = "root"
  description = "Username for the master DB user"
}

variable "max_capacity" {
  type        = string
  default     = 8
  description = "The maximum capacity of the serverless cluster"
}

variable "min_capacity" {
  type        = string
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

variable "performance_insights" {
  type        = bool
  default     = false
  description = "Specifies whether Performance Insights is enabled or not"
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Amount of time in days to retain Performance Insights data. Valida values are 7, 731 (2 years) or a multiple of 31. When specifying performance_insights_retention_period, performance_insights needs to be set to true"
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
  default     = {}
  description = "A mapping of tags to assign to the bucket"
}

variable "timeout_action" {
  type        = string
  default     = "RollbackCapacityChange"
  description = "The action to take when the timeout is reached"
}
