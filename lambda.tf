resource "aws_lambda_layer_version" "lambda_psycopg2_layer" { 
    layer_name = "layer_content" 
    compatible_runtimes = ["python3.12"] 
    filename = "layer_content.zip" 
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
  source_file = "handler.py"
  output_path = "acme_corporation_payload.zip"
}

resource "aws_lambda_function" "acme_corporation" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "acme_corporation_payload.zip"
  function_name = "acme_corporation"
  role          = aws_iam_role.acme_assume_role.arn
  handler       = "handler.lambda_handler"

  source_code_hash = data.archive_file.acme_corporation.output_base64sha256

  runtime = "python3.12"
  architectures = ["x86_64"]
  layers = [aws_lambda_layer_version.lambda_psycopg2_layer.arn]
  environment {
    variables = {
      foo = "bar"
    }
  }
}