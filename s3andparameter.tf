resource "random_id" "s3_bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket = "avi-saar-logs-aws${random_id.s3_bucket_id.hex}"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.bucket.arn}/*"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}


resource "aws_ssm_parameter" "hello_parameter" {
  name        = "/myapp/hello_parameter"
  description = "Parameter to store the 'hello' value"
  type        = "String"
  value       = "Hello, From Avi & Saar"
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.hello_parameter.arn,
    ]
  }
}