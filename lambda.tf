data "archive_file" "welcome" {
  type        = "zip"
  source_file = "test.py"
  output_path = "test.zip"
}

data "archive_file" "post_authentication" {
  type        = "zip"
  source_file = "myfunction.py"
  output_path = "myfunction.zip"
}

resource "aws_lambda_function" "demo_lambda" {
  filename         = data.archive_file.welcome.output_path
  function_name    = "testing"
  role             = aws_iam_role.lambda_role.arn
  handler          = "test.lambda_handler"
  runtime          = "python3.9"
  timeout          = 300
  source_code_hash = data.archive_file.welcome.output_base64sha256

  environment {
    variables = {
      hello_value = aws_ssm_parameter.hello_parameter.value
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attach
  ]

}

resource "aws_lambda_function" "myfunction" {
  filename         = "myfunction.zip"
  function_name    = "myfunction"
  role             = aws_iam_role.cognito_role.arn
  handler          = "myfunction.lambda_handler"
  runtime          = "python3.9"
  timeout          = 300
  source_code_hash = data.archive_file.post_authentication.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.my_table.name
      BUCKET_NAME    = aws_s3_bucket.bucket.bucket
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.allow_web.id]
  }
}

resource "aws_lambda_permission" "store_user_to_dynamodb_permission" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myfunction.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}

