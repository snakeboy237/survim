resource "aws_iam_policy" "alb_controller_policy" {
  name = "${var.environment}-alb-controller-policy"

  policy = file("${path.module}/iam_policies/alb_controller_policy.json") # I'll show content below
}

resource "aws_iam_role" "alb_controller_role" {
  name = "${var.environment}-alb-controller-role"

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
    Name = "${var.environment}-alb-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}
