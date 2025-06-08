# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS CONFIGURATION
# This section defines Security Groups for each major component in our architecture:
# - ALB: Public entry point for HTTPS traffic
# - Backend API: Private service only reachable from ALB
# - Lambda Function: Sends events to Kafka (Producer)
# - Kafka Cluster: Receives events from Lambda and serves them to AI Consumer
# - AI Detection Service: Consumes Kafka events, writes results to S3/DB
# This ensures least privilege access and tightly controls communication paths.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# ALB SECURITY GROUP
# Allows inbound HTTPS/HTTP traffic from the Internet (0.0.0.0/0) to the ALB
# ALB will then forward traffic to private Backend API
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Allow inbound HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow HTTP (port 80) for redirect to HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (port 443) for secure user traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic — so ALB can forward traffic to Backend API
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKEND API SECURITY GROUP
# Allows inbound traffic ONLY from ALB (on port 443)
# Allows outbound traffic to S3 + DB for storage and metadata
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "backend_api_sg" {
  name        = var.backend_api_sg_name
  description = "Allow inbound from ALB, outbound to S3 + DB"
  vpc_id      = aws_vpc.main_vpc.id

  # Only allow HTTPS traffic from ALB SG → no external access
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow outbound traffic to S3, DB, and other required services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Can be tightened later with VPC Endpoints
  }

  tags = {
    Name = var.backend_api_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA SECURITY GROUP
# No inbound traffic (Lambda is invoked by AWS)
# Allows outbound traffic to Kafka (to produce messages) and S3 (optional metadata access)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "lambda_sg" {
  name        = var.lambda_sg_name
  description = "Lambda SG for Kafka producer"
  vpc_id      = aws_vpc.main_vpc.id

  # No ingress needed — Lambda runs in response to S3 event, not external traffic

  # Allow outbound traffic to Kafka (port 9092)
  egress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka_sg.id]
  }

  # Allow outbound traffic to S3 and other services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.lambda_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# KAFKA SECURITY GROUP
# Allows inbound traffic from Lambda (Producer) and AI Detection Service (Consumer)
# Allows outbound traffic for cluster internals and monitoring
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "kafka_sg" {
  name        = var.kafka_sg_name
  description = "Kafka SG → allows Lambda producer + AI Detection consumer"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound traffic from Lambda + AI Detection on port 9092
  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [
      aws_security_group.lambda_sg.id,
      aws_security_group.ai_sg.id
    ]
  }

  # Allow outbound traffic for Kafka internals, monitoring, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.kafka_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AI DETECTION SECURITY GROUP
# Allows inbound traffic from Kafka (to consume messages)
# Allows outbound traffic to S3 Final Bucket + DB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ai_sg" {
  name        = var.ai_sg_name
  description = "AI Detection SG → listens to Kafka, sends to S3/DB"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound traffic from Kafka on port 9092
  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka_sg.id]
  }

  # Allow outbound traffic to S3 Final Bucket, DB, and monitoring systems
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ai_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CLUSTER SECURITY GROUP
# Allows required traffic to the EKS cluster control plane
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow all traffic within the cluster nodes and EKS control plane
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] # Your VPC range → cluster internal traffic
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-eks-cluster-sg"
  }
}
