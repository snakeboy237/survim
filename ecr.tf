# ---------------------------------------------------------------------------------------------------------------------
# ECR REPOSITORIES
# This creates two ECR repositories:
# - frontend → stores your frontend app Docker image
# - backend  → stores your backend API Docker image
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "repos" {
  for_each = toset([
    "frontend-repo",
    "backend-repo"
  ])

  name                 = "${var.environment}-${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}-${each.value}"
    Environment = var.environment
  }
}
