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

variable "s3_buckets_map" {
  description = "Mapping of logical bucket names to real bucket names"
  type = map(string)
  default = {
    bucket1 = "temp-image-bucket"   # Replace with your desired bucket name
    bucket2 = "final-image-bucket"  # Replace with your desired bucket name
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

}

