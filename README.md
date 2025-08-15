# Aurora Serverless v2 Terraform Module

A Terraform module for deploying AWS Aurora Serverless v2 clusters with support for both PostgreSQL and MySQL engines.

## Security & Compliance

### **FedRAMP & CMMC Compliance**

This module is designed to meet **FedRAMP High** and **CMMC Level 3+** requirements through:

- **FIPS 140-2 Level 3 Encryption**: Customer-managed KMS keys (default configuration)
- **Data Sovereignty**: Full control over encryption key lifecycle
- **Audit Trail**: Complete CloudTrail logging of all key operations
- **Snapshot Protection**: KMS keys persist independently of database lifecycle

### **Encryption Options**

| Type                           | Compliance Level       | Use Case               | Key Lifecycle                      |
| ------------------------------ | ---------------------- | ---------------------- | ---------------------------------- |
| **Customer Managed** (Default) | FedRAMP High, CMMC L3+ | Production, Compliance | Protected from `terraform destroy` |
| AWS Managed                    | Basic compliance       | Development, Testing   | AWS managed                        |

**Important**: Customer-managed KMS keys are protected from deletion to preserve snapshot access. See [KMS Key Management](#kms-key-management) for details.

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

| Name                            | Description                                                                         | Type           | Default                                                               | Required |
| ------------------------------- | ----------------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------- | :------: |
| application                     | Application name for resource naming and tagging                                    | `string`       | `"yourapp"`                                                           |    no    |
| backup_cross_account_role_arns  | List of cross-account AWS Backup role ARNs for cross-account backup operations      | `list(string)` | `[]`                                                                  |    no    |
| backup_retention_period         | The backup retention period in days                                                 | `number`       | `7`                                                                   |    no    |
| cluster_count                   | The number of Aurora Serverless v2 cluster instances to create                      | `number`       | `2`                                                                   |    no    |
| create_kms_key                  | Whether to create a new customer-managed KMS key                                    | `bool`         | `true`                                                                |    no    |
| database_name                   | The name of the database                                                            | `string`       | `"auroradevdb"`                                                       |    no    |
| db_subnet_group_name            | The name of the DB subnet group                                                     | `string`       | `"app_db_subnet_group"`                                               |    no    |
| deletion_protection             | If the DB cluster should have deletion protection enabled                           | `bool`         | `false`                                                               |    no    |
| enable_backup_service           | Whether to allow AWS Backup service to use the KMS key                              | `bool`         | `true`                                                                |    no    |
| encryption_type                 | Type of encryption - 'customer-managed' (FedRAMP compliant) or 'aws-managed'        | `string`       | `"customer-managed"`                                                  |    no    |
| engine_type                     | Database engine type - postgresql or mysql                                          | `string`       | `"postgresql"`                                                        |    no    |
| engine_version                  | The version of the database engine. If not specified, uses engine-specific defaults | `string`       | `null`                                                                |    no    |
| environment                     | Infrastructure environment - dev, test, prod, etc.                                  | `string`       | `"infra"`                                                             |    no    |
| kms_allowed_services            | List of AWS services allowed to use the KMS key for Aurora encryption               | `list(string)` | `["rds.amazonaws.com", "logs.amazonaws.com", "backup.amazonaws.com"]` |    no    |
| kms_key_deletion_window_in_days | Number of days to retain KMS key before permanent deletion (7-30)                   | `number`       | `7`                                                                   |    no    |
| kms_key_id                      | ARN of existing customer-managed KMS key (when create_kms_key is false)             | `string`       | `null`                                                                |    no    |
| kms_multi_region                | Whether to create a Multi-Region Key (MRK) for cross-region Aurora operations       | `bool`         | `false`                                                               |    no    |
| master_password                 | The master password for the database                                                | `string`       | `"yourpassword"`                                                      |    no    |
| master_username                 | The master username for the database                                                | `string`       | `"yourusername"`                                                      |    no    |
| max_capacity                    | The maximum capacity for the Aurora Serverless v2 cluster                           | `number`       | `16.0`                                                                |    no    |
| min_capacity                    | The minimum capacity for the Aurora Serverless v2 cluster                           | `number`       | `2.0`                                                                 |    no    |
| preferred_backup_window         | The daily time range during which automated backups are created                     | `string`       | `"03:00-04:00"`                                                       |    no    |
| preferred_maintenance_window    | The weekly time range during which system maintenance can occur                     | `string`       | `"sun:04:30-sun:08:00"`                                               |    no    |
| skip_final_snapshot             | Determines whether a final DB snapshot is created before the DB cluster is deleted  | `bool`         | `true`                                                                |    no    |
| tags                            | Additional tags to apply to all resources                                           | `map(string)`  | `{}`                                                                  |    no    |
| vpc_security_group_ids          | A list of VPC security group IDs                                                    | `list(string)` | `["app_security_group_id"]`                                           |    no    |

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

## Cross-Region Support

### **Multi-Region KMS Keys**

The module supports both single-region and multi-region KMS keys for cross-region Aurora operations:

| Key Type                    | Use Case                | Cross-Region Capability                    | Configuration              |
| --------------------------- | ----------------------- | ------------------------------------------ | -------------------------- |
| **Single-Region** (Default) | Standard deployments    | Manual snapshot copying with re-encryption | `kms_multi_region = false` |
| **Multi-Region**            | Cross-region operations | Seamless cross-region snapshot access      | `kms_multi_region = true`  |

#### Single-Region Keys (Default)

```hcl
module "aurora_single_region" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Standard single-region configuration (default)
  kms_multi_region = false  # Default

  database_name = "my_app"
  application   = "my-application"
  # Other configuration...
}
```

#### Multi-Region Keys

```hcl
module "aurora_multi_region" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Enable multi-region KMS key
  kms_multi_region = true

  database_name = "cross_region_app"
  application   = "global-application"
  # Other configuration...
}
```

### **Cross-Region Deployment Strategies**

#### Strategy 1: Multi-Region Keys (Recommended for Cross-Region Use)

- **Best for**: Applications requiring cross-region snapshot copying
- **Benefits**: Seamless cross-region operations, no re-encryption needed
- **Considerations**: Slightly higher cost, available in specific regions

#### Strategy 2: Single-Region Keys with Cross-Region Copying

- **Best for**: Region-specific deployments with occasional cross-region needs
- **Benefits**: Lower cost, broader region availability
- **Process**: Manual snapshot copying with re-encryption to target region key

### **External KMS Key Integration**

For existing KMS key infrastructure, reference the `test/external-kms-key/` example:

```hcl
# Create your own multi-region KMS key
resource "aws_kms_key" "aurora_mrk" {
  description         = "Multi-Region KMS Key for Aurora"
  multi_region        = true
  enable_key_rotation = true

  # Use same policy as module's internal key
  policy = jsonencode({
    # ... complete policy from test/external-kms-key/main.tf
  })
}

# Use external key with Aurora module
module "aurora_external_mrk" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  encryption_type = "customer-managed"
  create_kms_key  = false
  kms_key_id     = aws_kms_key.aurora_mrk.arn

  database_name = "external_key_db"
  # Other configuration...
}
```

## KMS Key Management

### **Terraform Destroy Behavior**

When using customer-managed keys (default), the KMS key is protected from deletion during `terraform destroy`:

1. **Database resources** are destroyed normally
2. **KMS key persists** with a 7-day deletion window (configurable)
3. **Snapshots remain accessible** for future restoration

This design ensures compliance with data retention requirements and prevents accidental data loss.

### **Key Configuration Examples**

#### Customer-Managed Key (Default - FedRAMP/CMMC Compliant)

```hcl
module "aurora_compliant" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Encryption configuration (defaults)
  encryption_type = "customer-managed"  # Default
  create_kms_key  = true                # Default
  kms_key_deletion_window_in_days = 7   # Default

  # Other configuration...
  database_name = "compliance_db"
  application   = "secure-app"
}
```

#### Use Existing Customer-Managed Key

```hcl
module "aurora_existing_key" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Use existing key
  encryption_type = "customer-managed"
  create_kms_key  = false
  kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Other configuration...
  database_name = "existing_key_db"
}
```

#### AWS Managed Key (Development/Testing)

```hcl
module "aurora_dev" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Use AWS managed key (simpler, less secure)
  encryption_type = "aws-managed"

  # Other configuration...
  database_name = "dev_db"
  environment   = "development"
}
```

#### Cross-Account Backup with AWS Backup

```hcl
module "aurora_cross_account_backup" {
  source = "git::https://github.com/your-org/terraform-y337-aurora-serverless.git?ref=v0.2.0"

  # Enable cross-account backup support
  backup_cross_account_role_arns = [
    "arn:aws:iam::111111111111:role/BackupServiceRole",
    "arn:aws:iam::222222222222:role/CentralBackupRole"
  ]

  # Ensure backup service is enabled (default: true)
  enable_backup_service = true

  # Standard configuration
  database_name = "prod_db"
  application   = "multi-account-app"
  environment   = "production"

  # Other configuration...
}
```

### **Cross-Account Backup Setup**

For organizations using centralized backup accounts or cross-account backup strategies:

1. **Create backup roles** in target accounts with appropriate permissions
2. **Add role ARNs** to `backup_cross_account_role_arns` variable
3. **KMS key policy** automatically grants necessary permissions
4. **AWS Backup** can now access encrypted snapshots across accounts

**Required Cross-Account Role Permissions:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "backup:StartBackupJob",
        "backup:StartRestoreJob",
        "backup:StartCopyJob"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Compliance Guidelines**

- **FedRAMP High**: Requires customer-managed keys (default configuration)
- **CMMC Level 3+**: Customer-managed keys with FIPS 140-2 Level 3 validation
- **Cross-Account Backup**: Customer-managed keys with cross-account role access
- **Development**: AWS managed keys acceptable for non-production workloads

## Security Considerations

- **KMS Encryption**: Customer-managed KMS keys provide FIPS 140-2 Level 3 compliance
- **Key Rotation**: Automatic annual rotation enabled for customer-managed keys
- **Network Security**: Deploy in private subnets with appropriate security groups
- **Password Management**: Use AWS Secrets Manager or similar for production passwords
- **Access Control**: Implement least-privilege IAM policies
- **Monitoring**: Enable CloudTrail and CloudWatch logs for comprehensive audit trails

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
