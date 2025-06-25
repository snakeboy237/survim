# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKETS CONFIGURATION
# This section creates the two S3 buckets used in the architecture:
# - bucket1 (TEMP): receives raw image uploads from the frontend/backend, triggers processing, auto-deletes
# - bucket2 (FINAL): stores processed images and AI detection results
# Both buckets use:
# - Encryption enabled
# ---------------------------------------------------------------------------------------------------------------------

# Create Both Buckets 
resource "aws_s3_bucket" "bucket1" {
  bucket   = var.bucket1
  provider = aws.use1
  force_destroy = true
  tags = {
    Name        = var.bucket1
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "bucket2" {
  bucket   = var.bucket2
  provider = aws.eu_central_1
  force_destroy = true
  tags = {
    Name        = var.bucket2
    Environment = var.environment
  }
}



# Apply encryption to all buckets
# Encryption for bucket1
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket1_sse" {
  provider = aws.use1
  bucket   = aws_s3_bucket.bucket1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Encryption for bucket2
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket2_sse" {
  provider = aws.eu_central_1
  bucket   = aws_s3_bucket.bucket2.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle for bucket1
resource "aws_s3_bucket_lifecycle_configuration" "temp_bucket_lifecycle" {
  provider = aws.use1
  bucket   = aws_s3_bucket.bucket1.id

  rule {
    id     = "AutoDeleteTempImages"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 1
    }
  }
}
