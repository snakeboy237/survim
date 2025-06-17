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

  provider = aws
  force_destroy = true
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
  for_each = { for k, v in aws_s3_bucket.buckets : k => v if k == "bucket1" }

  bucket = each.value.id

  rule {
    id     = "AutoDeleteTempImages"
    status = "Enabled"

    filter { # <--- REQUIRED to avoid warning
      prefix = "" # Matches all objects
    }

    expiration {
      days = 1
    }
  }
}

