# Test VPC Infrastructure
module "test_vpc" {
  source = "./vpc"

  vpc_name    = "aurora-test-vpc"
  environment = "test"

  tags = {
    Purpose = "Aurora Serverless Testing"
    Owner   = "DevOps Team"
  }
}

# Test PostgreSQL Aurora Serverless v2 (Default Engine) - COMMENTED OUT FOR MYSQL-ONLY TEST
# module "aurora_postgresql" {
#   source = "../"

#   # Engine configuration (PostgreSQL is default)
#   engine_type = "postgresql"

#   # Database configuration
#   database_name = "testpgdb"
#   application   = "aurora-test-pg"
#   environment   = "test"

#   # Networking
#   db_subnet_group_name   = module.test_vpc.db_subnet_group_name
#   vpc_security_group_ids = [module.test_vpc.aurora_security_group_id]

#   # Authentication
#   master_username = "testuser"
#   master_password = "TestPassword123!"

#   # Test-friendly settings
#   skip_final_snapshot = true
#   deletion_protection = false
#   min_capacity        = 0.5
#   max_capacity        = 1.0
#   cluster_count       = 1

#   # Backup settings
#   backup_retention_period = 1

#   tags = {
#     TestEngine = "postgresql"
#     TestType   = "integration"
#   }
# }

# Test MySQL Aurora Serverless v2
module "aurora_mysql" {
  source = "../"

  # Engine configuration
  engine_type = "mysql"

  # Database configuration
  database_name = "testmysqldb"
  application   = "aurora-test-mysql"
  environment   = "test"

  # Networking
  db_subnet_group_name   = module.test_vpc.db_subnet_group_name
  vpc_security_group_ids = [module.test_vpc.aurora_security_group_id]

  # Authentication
  master_username = "testuser"
  master_password = "TestPassword123!"

  # Test-friendly settings
  skip_final_snapshot = true
  deletion_protection = false
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cluster_count       = 1

  # Backup settings
  backup_retention_period = 1

  tags = {
    TestEngine = "mysql"
    TestType   = "integration"
  }
}
