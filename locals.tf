# ensure unique resource names
resource "random_id" "resource_id" {
  byte_length = 4
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  env        = terraform.workspace
  partition  = data.aws_partition.current.partition
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Engine-specific configurations
  engine_configs = {
    postgresql = {
      engine          = "aurora-postgresql"
      default_version = "15.4"
      cloudwatch_logs = ["postgresql"]
      default_port    = 5432
    }
    mysql = {
      engine          = "aurora-mysql"
      default_version = "8.0.mysql_aurora.3.04.0"
      cloudwatch_logs = ["audit", "error", "general", "slowquery"]
      default_port    = 3306
    }
  }

  # Computed engine values
  engine_config           = local.engine_configs[var.engine_type]
  engine                  = local.engine_config.engine
  engine_version          = var.engine_version != null ? var.engine_version : local.engine_config.default_version
  cloudwatch_logs_exports = local.engine_config.cloudwatch_logs
  port                    = local.engine_config.default_port

  # Common tags
  common_tags = merge(
    {
      Environment = var.environment
      Application = var.application
      Engine      = var.engine_type
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
