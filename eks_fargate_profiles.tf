# ---------------------------------------------------------------------------------------------------------------------
# EKS FARGATE PROFILES
# Creates Fargate profiles → pods with matching labels run on Fargate
# ---------------------------------------------------------------------------------------------------------------------

# Backend API Fargate Profile
resource "aws_eks_fargate_profile" "backend_api_profile" {
  cluster_name           = aws_eks_cluster.main_eks.name
  fargate_profile_name   = "${var.environment}-backend-api-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_ai.id
  ]

  selector {
    namespace = "backend-api"
  }

  tags = {
    Name = "${var.environment}-backend-api-profile"
  }
}

# AI Detection Fargate Profile
resource "aws_eks_fargate_profile" "ai_detection_profile" {
  cluster_name           = aws_eks_cluster.main_eks.name
  fargate_profile_name   = "${var.environment}-ai-detection-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_ai.id
  ]

  selector {
    namespace = "ai-detection"
  }

  tags = {
    Name = "${var.environment}-ai-detection-profile"
  }
}

resource "aws_eks_fargate_profile" "frontend" {
  cluster_name           = aws_eks_cluster.main_eks.name
  fargate_profile_name   = "frontend-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn

  subnet_ids = [
    aws_subnet.public_subnet.id
  ]

  selector {
    namespace = "frontend"
  }

  tags = {
    Name = "${var.environment}-frontend-profile"
  }
}


# Generic Fargate Profile
resource "aws_eks_fargate_profile" "generic_profile" {
  cluster_name           = aws_eks_cluster.main_eks.name
  fargate_profile_name   = "${var.environment}-generic-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_ai.id,
    aws_subnet.private_subnet_db.id,
    aws_subnet.private_subnet_kafka.id
  ]

  selector {
    namespace = "default"
  }

  tags = {
    Name = "${var.environment}-generic-profile"
  }
}

# IAM Role for Fargate Pods
resource "aws_iam_role" "eks_fargate_pod_role" {
  name = "${var.environment}-eks-fargate-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.environment}-eks-fargate-pod-role"
  }
}

# Attach basic execution policy for Fargate Pods (required)
resource "aws_iam_role_policy_attachment" "eks_fargate_pod_role_attachment" {
  role       = aws_iam_role.eks_fargate_pod_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}
