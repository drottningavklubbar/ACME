resource "aws_s3_bucket" "acme" {
  bucket = "acme-corporation-adventure-bucket"

  tags = {
    Name = "ACME Corporation Database Adventure"
  }
  force_destroy = true
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.acme_corporation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.acme.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.acme.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.acme_corporation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
