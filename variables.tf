#Environment Name
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
}

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

variable "s3_buckets_map" {
  description = "Mapping of logical bucket names to real bucket names"
  type = map(string)
  default = {
    bucket1 = "temp-image-bucket-12345"   # TEMP bucket → lifecycle will be applied
    bucket2 = "final-image-bucket-12345"  # FINAL bucket → no lifecycle
  }
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

variable "kafka_sg_id" {
  description = "Security Group ID for MSK cluster"
  type        = string
}


variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI named profile to use"
  type        = string
  default     = "default"
}