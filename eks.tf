# ---------------------------------------------------------------------------------------------------------------------
# EKS CLUSTER CONFIGURATION
# Creates 1 EKS cluster (managed control plane)
# We will run all microservices inside this cluster using Fargate profiles
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eks_cluster" "main_eks" {
  name     = "${var.environment}-eks-cluster"
  version  = "1.28"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_ai.id,
      aws_subnet.private_subnet_db.id,
      aws_subnet.private_subnet_kafka.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name        = "${var.environment}-eks-cluster"
    Environment = var.environment
  }
}

# IAM Role for EKS Cluster (required)
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.environment}-eks-cluster-role"
  }
}

# IAM Role Policy Attachment for EKS Cluster Role (managed AWS policy)
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
