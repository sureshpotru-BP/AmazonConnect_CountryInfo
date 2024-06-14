data "archive_file" "init" {
  type        = "zip"
  #source_dir  = "${path.module}/lambda"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

resource "aws_lambda_function" "example" {
  filename         = "${path.module}/lambda/lambda_function.zip"
  function_name    = "AmazonConnect_CountryInfo"
  #role             = aws_iam_role.lambda_exec.arn
  role             = "arn:aws:iam::798499423242:role/basic-lambda"
  handler          = "lambda_function.lambda_handler"
  #filename         = "lambda_function.py"
  #source_code_hash = data.archive_file.init.output_base64sha256
  runtime          = "python3.11"
  timeout          = 15 # timeout in seconds

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

#resource "aws_lambda_event_source_mapping" "example" {
 # event_source_arn  = "arn:aws:kinesis:eu-west-2:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_stream_name}"
 # function_name     = aws_lambda_function.example.arn
 # starting_position = "LATEST"
 # batch_size        = 100
#}
