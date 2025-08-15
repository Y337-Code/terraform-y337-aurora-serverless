resource "aws_kms_key" "aurora_kms_key" {
  count = var.encryption_type == "customer-managed" && var.create_kms_key ? 1 : 0

  description              = "KMS Key for encrypting Aurora Serverless v2 DB and Logs"
  is_enabled               = true
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  multi_region             = var.kms_multi_region

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy-1"
    Statement = concat([
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${local.partition}:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Use of the Key by AWS Services"
        Effect = "Allow"
        Principal = {
          Service = var.enable_backup_service ? var.kms_allowed_services : [
            for service in var.kms_allowed_services :
            service if service != "backup.amazonaws.com"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              for service in (var.enable_backup_service ? var.kms_allowed_services : [
                for service in var.kms_allowed_services :
                service if service != "backup.amazonaws.com"
              ]) :
              "${replace(service, ".amazonaws.com", "")}.${local.region}.amazonaws.com"
            ]
          }
        }
      }
    ], length(var.backup_cross_account_role_arns) > 0 ? [
      {
        Sid    = "Allow Cross-Account Backup Access"
        Effect = "Allow"
        Principal = {
          AWS = var.backup_cross_account_role_arns
        }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
          "kms:ListGrants",
          "kms:RetireGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "backup.${local.region}.amazonaws.com"
          }
        }
      }
    ] : [])
  })

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-aurora-kms-key-${local.env}"
    }
  )
}

resource "aws_rds_cluster" "aurora_serverless_v2" {
  cluster_identifier     = "${var.application}-cluster-${local.env}"
  engine_mode            = "provisioned"
  engine                 = local.engine
  engine_version         = local.engine_version
  database_name          = var.snapshot_identifier == null ? var.database_name : null
  master_username        = var.snapshot_identifier == null ? var.master_username : null
  master_password        = var.snapshot_identifier == null ? var.master_password : null
  skip_final_snapshot    = var.skip_final_snapshot
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  kms_key_id             = local.effective_kms_key_id
  storage_encrypted      = true
  port                   = local.port

  # Snapshot restoration configuration
  snapshot_identifier = var.snapshot_identifier

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_time != null || var.use_latest_restorable_time ? [1] : []
    content {
      restore_type               = var.restore_type
      restore_to_time           = var.restore_to_time
      use_latest_restorable_time = var.use_latest_restorable_time
    }
  }

  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  enabled_cloudwatch_logs_exports = local.cloudwatch_logs_exports
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  deletion_protection             = var.deletion_protection

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.engine_type}-cluster-${local.env}"
    }
  )
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.cluster_count
  identifier         = "${local.env}-${var.database_name}-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_serverless_v2.id
  instance_class     = "db.serverless"
  engine             = local.engine
  engine_version     = local.engine_version

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.engine_type}-instance-${count.index}-${local.env}"
    }
  )
}
