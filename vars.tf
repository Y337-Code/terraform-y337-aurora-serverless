variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The name of the region Terraform will use."
}

# AWS Variables
variable "environment" {
  type        = string
  description = "Infrastructure environment - dev, test, prod, etc."
  default     = "infra"
}

variable "net_state_region" {
  type        = string
  default     = "us-east-1"
  description = "The region of the Terraform state."
}

variable "aws_region_a" {
  type    = string
  default = "us-east-1"
}

variable "aws_zone_a" {
  type    = string
  default = "a"
}

variable "aws_zone_b" {
  type    = string
  default = "b"
}

# Database Engine Configuration
variable "engine_type" {
  type        = string
  description = "Database engine type - postgresql or mysql"
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql"], var.engine_type)
    error_message = "Engine type must be either 'postgresql' or 'mysql'."
  }
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine. If not specified, uses engine-specific defaults."
  default     = null
}

variable "database_name" {
  type        = string
  description = "The name of the database."
  default     = "auroradevdb"
}

variable "application" {
  type        = string
  description = "Application name for resource naming and tagging"
  default     = "yourapp"
}

variable "master_username" {
  type        = string
  description = "The master username for the database."
  default     = "yourusername"
}

variable "master_password" {
  type        = string
  description = "The master password for the database."
  default     = "yourpassword"
  sensitive   = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted."
  default     = true
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the DB subnet group."
  default     = "app_db_subnet_group"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs."
  default     = ["app_security_group_id"]
}

variable "max_capacity" {
  type        = number
  description = "The maximum capacity for the Aurora Serverless v2 cluster."
  default     = 16.0
}

variable "min_capacity" {
  type        = number
  description = "The minimum capacity for the Aurora Serverless v2 cluster."
  default     = 2.0
}

variable "cluster_count" {
  type        = number
  description = "The number of Aurora Serverless v2 cluster instances to create."
  default     = 2
}

variable "deletion_protection" {
  type        = bool
  description = "If the DB cluster should have deletion protection enabled."
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "The backup retention period in days."
  default     = 7
}

variable "preferred_backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created."
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "The weekly time range during which system maintenance can occur."
  default     = "sun:04:30-sun:08:00"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources."
  default     = {}
}

# Snapshot Configuration
variable "snapshot_identifier" {
  type        = string
  description = "The identifier of the snapshot to restore from. If null, creates a new cluster."
  default     = null
}

variable "restore_type" {
  type        = string
  description = "Type of restore - 'full-copy' or 'copy-on-write'"
  default     = "full-copy"

  validation {
    condition     = contains(["full-copy", "copy-on-write"], var.restore_type)
    error_message = "Restore type must be either 'full-copy' or 'copy-on-write'."
  }
}

variable "restore_to_time" {
  type        = string
  description = "The time to restore to (for point-in-time recovery). Format: 2023-01-01T12:00:00.000Z"
  default     = null
}

variable "use_latest_restorable_time" {
  type        = bool
  description = "Whether to restore to the latest restorable time"
  default     = false
}

# KMS Configuration
variable "encryption_type" {
  type        = string
  description = "Type of encryption to use. 'customer-managed' (default, FedRAMP/CMMC compliant) or 'aws-managed' (simpler, less secure)"
  default     = "customer-managed"

  validation {
    condition     = contains(["customer-managed", "aws-managed"], var.encryption_type)
    error_message = "Encryption type must be either 'customer-managed' or 'aws-managed'."
  }
}

variable "create_kms_key" {
  type        = bool
  description = "Whether to create a new customer-managed KMS key. Only relevant when encryption_type is 'customer-managed'."
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "ARN of an existing customer-managed KMS key to use. Only relevant when create_kms_key is false."
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  description = "Number of days to retain the KMS key before permanent deletion (7-30 days). Provides protection against accidental deletion."
  default     = 7

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_allowed_services" {
  type        = list(string)
  description = "List of AWS services allowed to use the KMS key for Aurora encryption."
  default     = ["rds.amazonaws.com", "logs.amazonaws.com", "backup.amazonaws.com"]

  validation {
    condition = alltrue([
      for service in var.kms_allowed_services :
      can(regex("^[a-z0-9-]+\\.amazonaws\\.com$", service))
    ])
    error_message = "All services must be valid AWS service endpoints (e.g., 'rds.amazonaws.com')."
  }
}

variable "backup_cross_account_role_arns" {
  type        = list(string)
  description = "List of cross-account AWS Backup service role ARNs that need access to decrypt Aurora snapshots for cross-account backup operations."
  default     = []

  validation {
    condition = alltrue([
      for arn in var.backup_cross_account_role_arns :
      can(regex("^arn:[^:]+:iam::[0-9]{12}:role/.+$", arn))
    ])
    error_message = "All ARNs must be valid IAM role ARNs (e.g., 'arn:aws:iam::123456789012:role/BackupRole')."
  }
}

variable "enable_backup_service" {
  type        = bool
  description = "Whether to allow AWS Backup service to use the KMS key for backup operations."
  default     = true
}

variable "kms_multi_region" {
  type        = bool
  description = "Whether to create a Multi-Region Key (MRK) for cross-region Aurora operations. Set to true for cross-region snapshot copying, false for single-region use."
  default     = false
}
