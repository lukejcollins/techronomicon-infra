# Create an s3 bucket for the application static
resource "aws_s3_bucket" "techronomicon" {
  bucket = var.TECHRONOMICON_STORAGE_BUCKET_NAME
}

resource "aws_s3_bucket_cors_configuration" "techronomicon_cors" {
  bucket = aws_s3_bucket.techronomicon.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "techronomicon_policy" {
  bucket = aws_s3_bucket.techronomicon.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.TECHRONOMICON_STORAGE_BUCKET_NAME}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "techronomicon" {
  bucket = aws_s3_bucket.techronomicon.id

  block_public_acls   = false
  block_public_policy = false
}
