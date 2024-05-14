resource "aws_iam_role" "lambda_exec" {
  name                 = "${var.lambda_name}-iam-role"
  description          = "Allows Lambda functions to call AWS services on your behalf."
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.account_prefix}-pol_PlatformUserBoundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.lambda_name}-iam-policy"
  description = "Read access to Kinesis Stream, write access to S3 Bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "S3ReadBkt",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Sid    = "S3WriteBkt",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Sid    = "CreateCloudWatchLogGroup",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup"
        ],
        Resource = "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Sid    = "CloudWatchLogging",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"
      },
      {
        Sid    = "KinesisReadStrm",
        Effect = "Allow",
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords"
        ],
        Resource = [
          "arn:aws:kinesis:eu-west-2:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_stream_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
