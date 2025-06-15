# VPC Outputs
output "vpc_id" {
  description = "ID of the test VPC"
  value       = module.test_vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the test VPC"
  value       = module.test_vpc.vpc_cidr_block
}

# Generic Aurora Database Outputs (works for both PostgreSQL and MySQL)
# Currently configured for MySQL testing - change module reference as needed

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aurora_mysql.aurora_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora_mysql.aurora_reader_endpoint
}

output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = module.aurora_mysql.aurora_cluster_id
}

output "aurora_engine" {
  description = "Aurora database engine"
  value       = module.aurora_mysql.aurora_engine
}

output "aurora_engine_version" {
  description = "Aurora engine version"
  value       = module.aurora_mysql.aurora_engine_version
}

output "aurora_port" {
  description = "Aurora database port"
  value       = module.aurora_mysql.aurora_port
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = module.aurora_mysql.aurora_database_name
}

output "aurora_master_username" {
  description = "Aurora master username"
  value       = module.aurora_mysql.aurora_master_username
}

output "aurora_kms_key_id" {
  description = "KMS key ID used for Aurora encryption"
  value       = module.aurora_mysql.aurora_kms_key_id
}

# Connection Information
output "connection_info" {
  description = "Database connection information"
  value = {
    endpoint = module.aurora_mysql.aurora_endpoint
    port     = module.aurora_mysql.aurora_port
    database = module.aurora_mysql.aurora_database_name
    engine   = module.aurora_mysql.aurora_engine
    username = module.aurora_mysql.aurora_master_username
  }
}

# Engine-specific outputs for validation
output "mysql_specific_info" {
  description = "MySQL-specific configuration details"
  value = {
    engine_family = "mysql"
    expected_port = 3306
    cloudwatch_logs = ["audit", "error", "general", "slowquery"]
  }
}
