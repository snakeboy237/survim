# VPC Name
variable "vpc_name" {
  description = "Name for the main VPC"
  type        = string
  default     = "main-vpc"
}

# Public Subnet Name
variable "public_subnet_name" {
  description = "Name for the public subnet"
  type        = string
  default     = "public-subnet"
}

# Private Subnet for AI Name
variable "private_subnet_ai_name" {
  description = "Name for the private subnet for AI (Kubernetes)"
  type        = string
  default     = "private-subnet-ai"
}

# Private Subnet for DB Name
variable "private_subnet_db_name" {
  description = "Name for the private subnet for DB"
  type        = string
  default     = "private-subnet-db"
}

variable "private_subnet_kafka_name" {
  description = "Name for the private subnet for Kafka"
  type        = string
  default     = "private-subnet-kafka"
  
}
variable "private_subnet_backendApi_name" {
  description = "Name for the private subnet for Backend API"
  type        = string
  default     = "private-subnet-backend-api"
}

# Internet Gateway Name
variable "igw_name" {
  description = "Name for the internet gateway"
  type        = string
  default     = "main-igw"
}

# Public Route Table Name
variable "public_route_table_name" {
  description = "Name for the public route table"
  type        = string
  default     = "public-rt"
}

# Elastic IP for Nat gateway
variable "nat_eip_name" {
  description = "Elastic IP for nat gateway"
   type = string
   default = "nat-eip"
}

variable "nat_gw_name" {
  description = "Elastic IP for nat gateway"
   type = string
   default = "nat-gw"
}

variable "private_route_table_name" {
  description = "Elastic IP for nat gateway"
   type = string
   default = "private-rt"
}

variable "alb_sg_name" {
  description = "Name of ALB Security Group"
  type        = string
  default     = "alb-sg"
}

variable "msk_sg_name" {
  description = "Name of MSK Security Group"
  type        = string
  default     = "msk-sg"
}

variable "ai_sg_name" {
  description = "Name of AI Detection Security Group"
  type        = string
  default     = "ai-sg"
}

variable "backend_api_sg_name" {
  description = "Name of AI Detection Security Group"
  type        = string
  default     = "backend-api-sg-name"
}

variable "lambda_sg_name" {
  description = "Name of AI Detection Security Group"
  type        = string
  default     = "lambda-sg-name"
}


variable "kafka_sg_name" {
  description = "Name of AI Detection Security Group"
  type        = string
  default     = "kafka-sg-name"
}



# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKETS VARIABLE → using MAP so you can assign logical names and real bucket names
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKETS CONFIGURATION
# This section creates the two S3 buckets used in the architecture:
# - bucket1 (TEMP): receives raw image uploads from the frontend/backend, triggers processing, auto-deletes
# - bucket2 (FINAL): stores processed images and AI detection results
# Both buckets use:
# - Encryption enabled
# ---------------------------------------------------------------------------------------------------------------------

# Create Both Buckets using for_each
resource "aws_s3_bucket" "buckets" {
  for_each = var.s3_buckets_map

  bucket = each.value

  tags = {
    Name        = each.value
    Environment = var.environment
  }
}


# Apply encryption to all buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "buckets_sse" {
  for_each = aws_s3_bucket.buckets

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# Apply Lifecycle Rule to TEMP Bucket Only (bucket1)
resource "aws_s3_bucket_lifecycle_configuration" "temp_bucket_lifecycle" {
  for_each = {for k, v in awaws_s3_bucket.buckets: k => v if k == "bucket1"}

  bucket = each.value.id

  rule {
    id     = "AutoDeleteTempImages"
    status = "Enabled"

    expiration {
      days = 1  # Automatically delete objects older than 1 day
    }
  }
}


variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

}


variable "kafka_cluster_name" {
  description = "Name of the Kafka Cluster"
  type        = string
  default     = "mini-ai-kafka-cluster"
}

variable "kafka_broker_count" {
  description = "Number of Kafka Broker Nodes"
  type        = number
  default     = 2 # You can set to 3 if you want high availability
}
variable "kafka_sg_id" {
  description = "ID of the Kafka Security Group"
  type        = string
  default     = ""
}