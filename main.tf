resource "aws_kms_key" "aurora_kms_key" {
  description              = "KMS Key for encrypting Aurora Serverless v2 DB and Logs"
  is_enabled               = true
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy-1"
    Statement = [
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
          Service = var.kms_allowed_services
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
              for service in var.kms_allowed_services :
              "${replace(service, ".amazonaws.com", "")}.${local.region}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

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
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  skip_final_snapshot    = var.skip_final_snapshot
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  kms_key_id             = aws_kms_key.aurora_kms_key.arn
  storage_encrypted      = true
  port                   = local.port

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
