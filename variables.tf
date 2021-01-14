variable "stack" {
  type        = string
  description = "The stack name for the Aurora Cluster"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Specifies whether any cluster modifications are applied immediately"
}

variable "auto_pause" {
  type        = bool
  default     = true
  description = "Whether to enable automatic pause"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones to deploy Aurora in"
}

variable "backup_retention_period" {
  type        = number
  default     = 1
  description = "The days to retain backups for"
}

variable "cidr_blocks" {
  type        = list(string)
  default     = null
  description = "List of CIDR blocks that should be allowed access to the Aurora cluster"
}

variable "cluster_family" {
  type        = string
  default     = "aurora5.6"
  description = "The family of the DB cluster parameter group"
}

variable "cluster_parameters" {
  type = list(object({
    name  = string
    value = string
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
    name  = string
    value = string
  }))
  default = null
  description = "A list of instance DB parameters to apply"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "A boolean indicating if the DB instance should have deletion protection enable"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch"
  type        = list(string)
  default     = []
}

variable "enable_http_endpoint" {
  type        = bool
  default     = false
  description = "Enable Aurora Serverless HTTP endpoint (Data API)"
}

variable "engine" {
  type        = string
  default     = "aurora"
  description = "The engine type of the Aurora cluster"
}

variable "engine_mode" {
  type        = string
  default     = "serverless"
  description = "The engine mode of the Aurora cluster"
}

variable "engine_version" {
  type        = string
  default     = "5.6.10a"
  description = "The engine version of the Aurora cluster"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Identifier of the final snapshot to create before deleting the cluster"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = null
  description = "Specify if mapping AWS IAM accounts to database accounts is enabled."
}

variable "iam_roles" {
  type        = list(string)
  default     = null
  description = "A list of IAM Role ARNs to associate with the cluster"
}

variable "instance_class" {
  type        = string
  default     = "db.r5.large"
  description = "The class of RDS instances to attach. Only for serverless engine_mode"
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "The number of RDS instances to attach. Only for serverless engine_mode"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The KMS key ID used for the storage encryption"
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
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  type        = string
  default     = null
}

variable "password" {
  type        = string
  description = "Password for the master DB user"
}

variable "performance_insights" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = ""
}

variable "permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

variable "publicly_accessible" {
  type        = string
  default     = false
  description = "Control if instances in cluster are publicly accessible"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs allowed to connect to Aurora"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Determines whether a final snapshot is created before deleting the cluster"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DB cluster is encrypted"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy Aurora in"
}

variable "username" {
  type        = string
  description = "Username for the master DB user"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
}
