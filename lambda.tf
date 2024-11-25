resource "aws_lambda_layer_version" "lambda_psycopg2_layer" {
  layer_name          = "psycopg2_lambda_layer4"
  compatible_runtimes = ["python3.13"]
  filename            = "./lambda_layer/psycopg2_lambda_layer.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "acme_assume_role" {
  name               = "acme_assume_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "acme_corporation" {
  type        = "zip"
  source_dir = "${path.module}/acme_solution"
  output_path = "${path.module}/acme_corporation_payload.zip"
}

resource "aws_lambda_function" "acme_corporation" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.acme_corporation.output_path
  function_name = "acme_corporation"
  role          = aws_iam_role.acme_assume_role.arn
  handler       = "handler.lambda_handler"

  source_code_hash = data.archive_file.acme_corporation.output_base64sha256

  runtime       = "python3.13"
  architectures = ["x86_64"]

  depends_on = [
    aws_iam_role_policy_attachment.acme_lambda_logs,
    aws_iam_role_policy_attachment.acme_s3
  ]

  layers = [aws_lambda_layer_version.lambda_psycopg2_layer.arn]

  environment {
    variables = {
      foo = "bar"
    }
  }
}

data "aws_iam_policy_document" "acme_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "acme_lambda_logging" {
  name        = "acme_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from ACME logs lambda"
  policy      = data.aws_iam_policy_document.acme_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "acme_lambda_logs" {
  role       = aws_iam_role.acme_assume_role.name
  policy_arn = aws_iam_policy.acme_lambda_logging.arn
}

data "aws_iam_policy_document" "acme_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.acme.arn}/*"]
  }
}

resource "aws_iam_policy" "acme_s3" {
  name        = "acme_s3"
  path        = "/"
  description = "IAM policy for getting the object from s3"
  policy      = data.aws_iam_policy_document.acme_s3.json
}

resource "aws_iam_role_policy_attachment" "acme_s3" {
  role       = aws_iam_role.acme_assume_role.name
  policy_arn = aws_iam_policy.acme_s3.arn
}