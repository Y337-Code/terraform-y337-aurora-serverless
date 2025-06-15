output "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  value       = aws_rds_cluster.aurora_serverless_v2.endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.aurora_serverless_v2.reader_endpoint
}

output "aurora_cluster_arn" {
  description = "Aurora cluster ARN"
  value       = aws_rds_cluster.aurora_serverless_v2.arn
}

output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.aurora_serverless_v2.id
}

output "aurora_master_username" {
  description = "Aurora cluster master username"
  value       = aws_rds_cluster.aurora_serverless_v2.master_username
  sensitive   = true
}

output "aurora_master_password" {
  description = "Aurora cluster master password"
  value       = aws_rds_cluster.aurora_serverless_v2.master_password
  sensitive   = true
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = aws_rds_cluster.aurora_serverless_v2.database_name
}

output "aurora_engine" {
  description = "Aurora database engine"
  value       = aws_rds_cluster.aurora_serverless_v2.engine
}

output "aurora_engine_version" {
  description = "Aurora database engine version"
  value       = aws_rds_cluster.aurora_serverless_v2.engine_version
}

output "aurora_port" {
  description = "Aurora database port"
  value       = aws_rds_cluster.aurora_serverless_v2.port
}

output "aurora_kms_key_id" {
  description = "KMS key ID used for Aurora encryption"
  value       = aws_kms_key.aurora_kms_key.key_id
}

output "aurora_kms_key_arn" {
  description = "KMS key ARN used for Aurora encryption"
  value       = aws_kms_key.aurora_kms_key.arn
}

output "aurora_cluster_instances" {
  description = "Aurora cluster instance identifiers"
  value       = aws_rds_cluster_instance.cluster_instances[*].identifier
}
