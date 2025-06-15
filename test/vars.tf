variable "aws_region" {
  type        = string
  description = "AWS region for test resources"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name for test resources"
  default     = "test"
}

variable "test_name_prefix" {
  type        = string
  description = "Prefix for test resource names"
  default     = "aurora-test"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for test resources"
  default = {
    Purpose   = "Testing Aurora Serverless Module"
    Owner     = "DevOps Team"
    Terraform = "true"
  }
}

# Aurora Serverless v2 Capacity Configuration
variable "min_capacity" {
  type        = number
  description = "Minimum Aurora Serverless v2 capacity (ACUs)"
  default     = 0.5

  validation {
    condition     = var.min_capacity >= 0.5 && var.min_capacity <= 128
    error_message = "Min capacity must be between 0.5 and 128 ACUs."
  }
}

variable "max_capacity" {
  type        = number
  description = "Maximum Aurora Serverless v2 capacity (ACUs)"
  default     = 2.0

  validation {
    condition     = var.max_capacity >= 0.5 && var.max_capacity <= 128
    error_message = "Max capacity must be between 0.5 and 128 ACUs."
  }
}
