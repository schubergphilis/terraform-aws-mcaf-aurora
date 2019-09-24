variable "stack" {
  type        = string
  description = "The stack name for the Aurora Cluster"
}

variable "database" {
  type        = string
  default     = null
  description = "The name of the first database to be created when the cluster is created"
}

variable "engine" {
  type        = string
  default     = "aurora"
  description = "The engine type of the Aurora cluster"
}

variable "engine_version" {
  type        = string
  default     = "5.6.10a"
  description = "The engine version of the Aurora cluster"
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
  description = "A list of DB parameters to apply"
}

variable "username" {
  type        = string
  description = "Username for the master DB user"
}

variable "password" {
  type        = string
  description = "Password for the master DB user"
}

variable "auto_pause" {
  type        = bool
  default     = true
  description = "Whether to enable automatic pause"
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

variable "iam_roles" {
  type        = list(string)
  default     = null
  description = "A list of IAM Role ARNs to associate with the cluster"
}

variable "cidr_blocks" {
  type        = list(string)
  default     = null
  description = "List of CIDR blocks that should be allowed access to the Aurora cluster"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs allowed to connect to Aurora"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones to deploy Aurora in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy Aurora in"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Specifies whether any cluster modifications are applied immediately"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DB cluster is encrypted"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The KMS key ID used for the storage encryption"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "A boolean indicating if the DB instance should have deletion protection enable"
}

variable "enable_data_api" {
  type        = bool
  default     = false
  description = "Whether or not to enable the data API"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Determines whether a final snapshot is created before deleting the cluster"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Identifier of the final snapshot to create before deleting the cluster"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket"
}
