# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA FUNCTION → S3 TEMP BUCKET TRIGGER → PRODUCES MESSAGE TO KAFKA
# ---------------------------------------------------------------------------------------------------------------------

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.environment}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.environment}-lambda-exec-role"
  }
}

# IAM Policy Attachment → Allow logs + Kafka + S3
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.environment}-lambda-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:DescribeTopic",
          "kafka:WriteData"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bucket1.arn,
          "${aws_s3_bucket.bucket1.arn}/*"
        ]
      }
    ]
  })
}


# Lambda Function
resource "aws_lambda_function" "s3_to_kafka_lambda" {
  function_name = "${var.environment}-s3-to-kafka-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  provider      = aws.ap_south_1
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "${path.module}/lambda_code/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_code/lambda.zip")


  timeout = 30

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_kafka.id] # Lambda in Kafka subnet
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [
    aws_security_group.lambda_sg,
    aws_subnet.private_subnet_kafka
  ]

  tags = {
    Name = "${var.environment}-s3-to-kafka-lambda"
  }
}

# S3 EVENT NOTIFICATION → Trigger Lambda
resource "aws_s3_bucket_notification" "temp_bucket_notification" {
  provider = aws.ap_south_1
  bucket = aws_s3_bucket.bucket1.id # Replace with your bucket name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_kafka_lambda.arn
    events              = ["s3:ObjectCreated:*"] # Trigger on image upload
    filter_prefix       = ""                     # Optional → you can filter specific folders
    filter_suffix       = ""                     # Optional → e.g., ".jpg"
  }

 // depends_on = [aws_lambda_permission.allow_s3_invoke_lambda]
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_kafka_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket1.arn
  # Replace with your bucket name
}
