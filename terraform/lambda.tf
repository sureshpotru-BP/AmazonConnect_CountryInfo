data "archive_file" "init" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/files/lambda.zip"
}

resource "aws_lambda_function" "example" {
  #filename         = "${path.module}/files/lambda.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  filename         = "CallBack_Final.zip"
  #source_code_hash = data.archive_file.init.output_base64sha256
  runtime          = "python3.8"

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = "arn:aws:kinesis:eu-west-2:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_stream_name}"
  function_name     = aws_lambda_function.example.arn
  starting_position = "LATEST"
  batch_size        = 100
}
