resource "aws_s3_bucket" "acme" {
  bucket = "acme-corporation-adventure-bucket"

  tags = {
    Name        = "ACME Corporation Database Adventure"
  }
  force_destroy = true
}