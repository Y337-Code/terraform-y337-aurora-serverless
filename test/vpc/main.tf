# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "test_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = var.vpc_name
      Environment = var.environment
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-igw"
      Environment = var.environment
    }
  )
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-public-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-private-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Private"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.test_igw]

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-nat-eip"
      Environment = var.environment
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "test_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.test_igw]

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-nat-gateway"
      Environment = var.environment
    }
  )
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-public-rt"
      Environment = var.environment
    }
  )
}

# Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_nat.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-private-rt"
      Environment = var.environment
    }
  )
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_rta" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_rta" {
  count = length(aws_subnet.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# DB Subnet Group for Aurora
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.vpc_name}-aurora-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-aurora-subnet-group"
      Environment = var.environment
    }
  )
}

# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  name_prefix = "${var.vpc_name}-aurora-sg"
  vpc_id      = aws_vpc.test_vpc.id
  description = "Security group for Aurora Serverless v2"

  # PostgreSQL port
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL access from VPC"
  }

  # MySQL port
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "MySQL access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.vpc_name}-aurora-sg"
      Environment = var.environment
    }
  )
}
