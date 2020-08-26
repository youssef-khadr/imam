variable "create_security_group" {
  description = "Whether to create security group for RDS cluster"
  type        = bool
}

variable "name" {
  description = "Name given resources"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to use"
  type        = list(string)
}

variable "replica_count" {
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
}

variable "allowed_security_groups" {
  description = "A list of Security Group ID's to allow access to."
  type        = list(string)

}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
}


variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
}

variable "username" {
  description = "Master DB username"
  type        = string
  default     = "root"
}

variable "password" {
  description = "Master DB password"
  type        = string
  default     = ""
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
}

variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
}

variable "preferred_maintenance_window" {
  description = "When to perform DB maintenance"
  type        = string
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = ""
}


variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

#variable "storage_encrypted" {
#  description = "Specifies whether the underlying storage layer should be encrypted"
#  type        = bool
#  default     = true
#}
#
#variable "kms_key_id" {
#  description = "The ARN for the KMS encryption key if one is set to the cluster."
#  type        = string
#  default     = ""
#}

variable "engine" {
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql"
  type        = string
  default     = "aurora"
}

variable "engine_version" {
  description = "Aurora database engine version."
  type        = string
  default     = "5.6.10a"
}



variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}



variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch"
  type        = list(string)
  default     = []
}


variable "engine_mode" {
  description = "The database engine mode. Valid values: global, parallelquery, provisioned, serverless, multimaster."
  type        = string
  default     = "provisioned"
}


variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "The existing subnet group name to use"
  type        = string
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster tags to snapshots."
  type        = bool
  default     = false
}


variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description."
  type        = string
  default     = "Managed by Terraform"
}

variable "permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}
variable "topic_arn" {}
variable "project" {}