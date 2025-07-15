resource "aws_s3_bucket" "xcode_releases" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "xcode_releases" {
  bucket = aws_s3_bucket.xcode_releases.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "xcode_releases" {
  bucket = aws_s3_bucket.xcode_releases.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "xcode_releases" {
  bucket = aws_s3_bucket.xcode_releases.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}