# Aurora Serverless v2 Test Environment

This directory contains a complete test environment for the Aurora Serverless v2 Terraform module, including both PostgreSQL and MySQL deployments.

## Overview

The test environment creates:

- A complete VPC with public/private subnets across 2 AZs
- Internet Gateway and NAT Gateway for connectivity
- DB subnet group for Aurora clusters
- Security groups with appropriate database access rules
- Two Aurora Serverless v2 clusters:
  - PostgreSQL cluster (default engine)
  - MySQL cluster

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Appropriate AWS permissions for:
  - VPC and networking resources
  - RDS Aurora clusters
  - KMS keys
  - Security groups

## Quick Start

1. **Copy the example variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your specific values (optional, defaults work for testing)

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Plan the deployment:**

   ```bash
   terraform plan
   ```

5. **Apply the configuration:**

   ```bash
   terraform apply
   ```

6. **View the outputs:**
   ```bash
   terraform output
   ```

## Test Scenarios

### PostgreSQL Testing

The test creates a PostgreSQL Aurora Serverless v2 cluster with:

- Engine: `aurora-postgresql`
- Version: Latest stable (15.4)
- CloudWatch logs: `["postgresql"]`
- Port: 5432
- Minimal capacity settings for cost efficiency

### MySQL Testing

The test creates a MySQL Aurora Serverless v2 cluster with:

- Engine: `aurora-mysql`
- Version: Latest stable (8.0.mysql_aurora.3.04.0)
- CloudWatch logs: `["audit", "error", "general", "slowquery"]`
- Port: 3306
- Minimal capacity settings for cost efficiency

## Validation Points

After deployment, verify:

1. **Both clusters are created successfully:**

   ```bash
   terraform output connection_info
   ```

2. **Engine-specific configurations are applied:**

   - PostgreSQL cluster uses port 5432
   - MySQL cluster uses port 3306
   - Appropriate CloudWatch log groups are created

3. **Networking is configured correctly:**

   - Clusters are in private subnets
   - Security groups allow appropriate database ports
   - DB subnet groups span multiple AZs

4. **KMS encryption is enabled:**
   - Both clusters use customer-managed KMS keys
   - Keys have appropriate policies for AWS services

## Connection Testing

### PostgreSQL Connection

```bash
# Get connection details
terraform output postgresql_cluster_endpoint
terraform output postgresql_port

# Example connection (from within VPC)
psql -h <endpoint> -p 5432 -U testuser -d testpgdb
```

### MySQL Connection

```bash
# Get connection details
terraform output mysql_cluster_endpoint
terraform output mysql_port

# Example connection (from within VPC)
mysql -h <endpoint> -P 3306 -u testuser -p testmysqldb
```

## Cost Management

The test environment is configured for minimal cost:

- `min_capacity = 0.5` (minimum Aurora Serverless v2 capacity)
- `max_capacity = 1.0` (low maximum to prevent scaling costs)
- `cluster_count = 1` (single instance per cluster)
- `backup_retention_period = 1` (minimal backup retention)
- `skip_final_snapshot = true` (no final snapshot on destroy)
- `deletion_protection = false` (allows easy cleanup)

## Cleanup

To destroy all test resources:

```bash
terraform destroy
```

**Note:** This will permanently delete all test databases and associated data.

## Development Workflow

1. **Make changes to the main module** (in parent directory)
2. **Test changes:**
   ```bash
   cd test
   terraform plan
   terraform apply
   ```
3. **Validate both engine types work correctly**
4. **Clean up test resources:**
   ```bash
   terraform destroy
   ```

## Troubleshooting

### Common Issues

1. **Insufficient AWS permissions:**

   - Ensure your AWS credentials have permissions for RDS, VPC, KMS, and EC2

2. **Region availability:**

   - Some AWS regions may not support all Aurora engine versions
   - Update `availability_zones` in variables if needed

3. **Resource limits:**

   - Check AWS service quotas for RDS clusters in your account
   - Ensure you're not exceeding VPC or subnet limits

4. **Terraform state issues:**
   - Use `terraform refresh` to sync state with actual resources
   - Consider using remote state for team development

### Getting Help

- Check Terraform plan output for detailed error messages
- Review AWS CloudTrail logs for permission issues
- Validate AWS service quotas in the AWS Console

## File Structure

```
test/
├── README.md                 # This file
├── main.tf                   # Main test configuration
├── variables.tf              # Test variables
├── outputs.tf                # Test outputs
├── terraform.tfvars.example  # Example configuration
└── vpc/
    ├── main.tf               # VPC infrastructure
    ├── variables.tf          # VPC variables
    └── outputs.tf            # VPC outputs
```
