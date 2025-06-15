# Aurora Serverless v2 Terraform Module

A Terraform module for deploying AWS Aurora Serverless v2 clusters with support for both PostgreSQL and MySQL engines.

## Features

- **Multi-Engine Support**: PostgreSQL (default) and MySQL
- **Aurora Serverless v2**: Automatic scaling with configurable capacity limits
- **KMS Encryption**: Customer-managed KMS keys for data encryption
- **CloudWatch Logs**: Engine-specific log exports
- **Flexible Configuration**: Comprehensive variable support
- **Production Ready**: Includes backup, maintenance windows, and security best practices

## Supported Database Engines

| Engine     | Version                           | CloudWatch Logs                          | Default Port |
| ---------- | --------------------------------- | ---------------------------------------- | ------------ |
| PostgreSQL | 15.4 (default)                    | `postgresql`                             | 5432         |
| MySQL      | 8.0.mysql_aurora.3.04.0 (default) | `audit`, `error`, `general`, `slowquery` | 3306         |

## Usage

### Basic PostgreSQL Deployment (Default)

```hcl
module "aurora_postgresql" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Database configuration
  database_name = "myapp"
  application   = "my-application"
  environment   = "production"

  # Networking
  db_subnet_group_name   = "my-db-subnet-group"
  vpc_security_group_ids = ["sg-12345678"]

  # Authentication
  master_username = "dbadmin"
  master_password = "SecurePassword123!"

  # Scaling configuration
  min_capacity = 0.5
  max_capacity = 16.0
}
```

### MySQL Deployment

```hcl
module "aurora_mysql" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Engine configuration
  engine_type = "mysql"

  # Database configuration
  database_name = "myapp"
  application   = "my-application"
  environment   = "production"

  # Networking
  db_subnet_group_name   = "my-db-subnet-group"
  vpc_security_group_ids = ["sg-12345678"]

  # Authentication
  master_username = "dbadmin"
  master_password = "SecurePassword123!"

  # Scaling configuration
  min_capacity = 0.5
  max_capacity = 16.0
}
```

### Advanced Configuration

```hcl
module "aurora_advanced" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Engine configuration
  engine_type    = "postgresql"
  engine_version = "14.9"  # Override default version

  # Database configuration
  database_name = "production_db"
  application   = "ecommerce-platform"
  environment   = "prod"

  # Networking
  db_subnet_group_name   = "prod-db-subnet-group"
  vpc_security_group_ids = ["sg-prod-db-access"]

  # Authentication
  master_username = "postgres"
  master_password = var.db_password  # Use variable for security

  # Scaling and performance
  min_capacity = 2.0
  max_capacity = 32.0
  cluster_count = 3

  # KMS configuration - add additional services as needed
  kms_allowed_services = [
    "rds.amazonaws.com",
    "logs.amazonaws.com",
    "backup.amazonaws.com",
    "lambda.amazonaws.com"
  ]

  # Backup and maintenance
  backup_retention_period      = 30
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:30-sun:08:00"
  deletion_protection          = true

  # Tags
  tags = {
    Owner       = "Platform Team"
    Environment = "Production"
    Project     = "E-commerce Platform"
    CostCenter  = "Engineering"
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 5.26 |
| random    | >= 3.5  |

## Providers

| Name   | Version |
| ------ | ------- |
| aws    | >= 5.26 |
| random | >= 3.5  |

## Inputs

| Name                         | Description                                                                         | Type           | Default                                       | Required |
| ---------------------------- | ----------------------------------------------------------------------------------- | -------------- | --------------------------------------------- | :------: |
| application                  | Application name for resource naming and tagging                                    | `string`       | `"company"`                                   |    no    |
| backup_retention_period      | The backup retention period in days                                                 | `number`       | `7`                                           |    no    |
| cluster_count                | The number of Aurora Serverless v2 cluster instances to create                      | `number`       | `2`                                           |    no    |
| database_name                | The name of the database                                                            | `string`       | `"auroradevmtrgrm"`                           |    no    |
| db_subnet_group_name         | The name of the DB subnet group                                                     | `string`       | `"app_db_subnet_group"`                       |    no    |
| deletion_protection          | If the DB cluster should have deletion protection enabled                           | `bool`         | `false`                                       |    no    |
| engine_type                  | Database engine type - postgresql or mysql                                          | `string`       | `"postgresql"`                                |    no    |
| engine_version               | The version of the database engine. If not specified, uses engine-specific defaults | `string`       | `null`                                        |    no    |
| environment                  | Infrastructure environment - dev, test, prod, etc.                                  | `string`       | `"infra"`                                     |    no    |
| kms_allowed_services         | List of AWS services allowed to use the KMS key for Aurora encryption               | `list(string)` | `["rds.amazonaws.com", "logs.amazonaws.com"]` |    no    |
| master_password              | The master password for the database                                                | `string`       | `"yourpassword"`                              |    no    |
| master_username              | The master username for the database                                                | `string`       | `"yourusername"`                              |    no    |
| max_capacity                 | The maximum capacity for the Aurora Serverless v2 cluster                           | `number`       | `1.0`                                         |    no    |
| min_capacity                 | The minimum capacity for the Aurora Serverless v2 cluster                           | `number`       | `0.5`                                         |    no    |
| preferred_backup_window      | The daily time range during which automated backups are created                     | `string`       | `"03:00-04:00"`                               |    no    |
| preferred_maintenance_window | The weekly time range during which system maintenance can occur                     | `string`       | `"sun:04:30-sun:08:00"`                       |    no    |
| skip_final_snapshot          | Determines whether a final DB snapshot is created before the DB cluster is deleted  | `bool`         | `true`                                        |    no    |
| tags                         | Additional tags to apply to all resources                                           | `map(string)`  | `{}`                                          |    no    |
| vpc_security_group_ids       | A list of VPC security group IDs                                                    | `list(string)` | `["app_security_group_id"]`                   |    no    |

## Outputs

| Name                     | Description                            |
| ------------------------ | -------------------------------------- |
| aurora_cluster_arn       | Aurora cluster ARN                     |
| aurora_cluster_id        | Aurora cluster identifier              |
| aurora_cluster_instances | Aurora cluster instance identifiers    |
| aurora_database_name     | Aurora database name                   |
| aurora_endpoint          | Aurora cluster endpoint                |
| aurora_engine            | Aurora database engine                 |
| aurora_engine_version    | Aurora database engine version         |
| aurora_kms_key_arn       | KMS key ARN used for Aurora encryption |
| aurora_kms_key_id        | KMS key ID used for Aurora encryption  |
| aurora_master_password   | Aurora cluster master password         |
| aurora_master_username   | Aurora cluster master username         |
| aurora_port              | Aurora database port                   |
| aurora_reader_endpoint   | Aurora cluster reader endpoint         |

## Version Compatibility

### v0.1.0 (PostgreSQL Only)

- Original PostgreSQL-only implementation
- Use this version for existing deployments
- No breaking changes planned

### v0.2.0+ (Multi-Engine)

- Supports both PostgreSQL and MySQL
- PostgreSQL remains the default engine
- Clean variable structure
- Enhanced outputs and documentation

## Testing

A comprehensive test environment is included in the `test/` directory:

```bash
cd test
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The test environment creates:

- Complete VPC with networking
- Both PostgreSQL and MySQL Aurora clusters
- All necessary security groups and subnet groups

See [test/README.md](test/README.md) for detailed testing instructions.

## Examples

### Connection Strings

#### PostgreSQL

```bash
# Standard connection
psql -h ${aurora_endpoint} -p ${aurora_port} -U ${master_username} -d ${database_name}

# With SSL (recommended)
psql "host=${aurora_endpoint} port=${aurora_port} dbname=${database_name} user=${master_username} sslmode=require"
```

#### MySQL

```bash
# Standard connection
mysql -h ${aurora_endpoint} -P ${aurora_port} -u ${master_username} -p ${database_name}

# With SSL (recommended)
mysql -h ${aurora_endpoint} -P ${aurora_port} -u ${master_username} -p ${database_name} --ssl-mode=REQUIRED
```

### Application Configuration

#### PostgreSQL (Node.js)

```javascript
const config = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  dialect: "postgres",
  ssl: true,
};
```

#### MySQL (Node.js)

```javascript
const config = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  database: process.env.DB_NAME,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  dialect: "mysql",
  ssl: true,
};
```

## Security Considerations

- **KMS Encryption**: All clusters use customer-managed KMS keys
- **Network Security**: Deploy in private subnets with appropriate security groups
- **Password Management**: Use AWS Secrets Manager or similar for production passwords
- **Access Control**: Implement least-privilege IAM policies
- **Monitoring**: Enable CloudWatch logs and monitoring

## Cost Optimization

- **Serverless v2**: Automatic scaling reduces costs during low usage
- **Capacity Limits**: Set appropriate min/max capacity for your workload
- **Backup Retention**: Adjust retention period based on requirements
- **Instance Count**: Use minimum instances needed for availability

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests in the `test/` directory
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

- Create an issue in the GitHub repository
- Review the test environment for examples
- Check AWS documentation for Aurora Serverless v2 specifics
