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
  default     = "auroradevmtrgrm"
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

# KMS Configuration
variable "kms_allowed_services" {
  type        = list(string)
  description = "List of AWS services allowed to use the KMS key for Aurora encryption."
  default     = ["rds.amazonaws.com", "logs.amazonaws.com"]

  validation {
    condition = alltrue([
      for service in var.kms_allowed_services :
      can(regex("^[a-z0-9-]+\\.amazonaws\\.com$", service))
    ])
    error_message = "All services must be valid AWS service endpoints (e.g., 'rds.amazonaws.com')."
  }
}
