resource "aws_s3_bucket" "avatars" {
  bucket = var.bucket_name
  tags = {
    Name        = "${var.bucket_name}"
    Environment = var.environment
  }
}