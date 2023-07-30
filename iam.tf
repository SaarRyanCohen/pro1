# IAM Role for "api-lambda-role"
resource "aws_iam_role" "lambda_role" {
  name = "api-lambda-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_policy" {
  name        = "${aws_iam_role.lambda_role.name}-policy"
  description = "IAM policy for a lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ],
        "Resource" : "*"
      }
    ]
  })
}



# IAM Role Policy Attachment for "api-lambda-role"
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_iam_role" "cognito_role" {
  name = "cognito_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cognito_project_policy" {
  name = "CognitoProjectPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "cognito_project_policy_attach" {
  role       = aws_iam_role.cognito_role.name
  policy_arn = aws_iam_policy.cognito_project_policy.arn
}

resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.cognito_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.cognito_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonCognitoDeveloperAuthenticatedIdentities" {
  role       = aws_iam_role.cognito_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoDeveloperAuthenticatedIdentities"
}

resource "aws_iam_role_policy_attachment" "AmazonCognitoPowerUser" {
  role       = aws_iam_role.cognito_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}



resource "aws_vpc_endpoint_policy" "example" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAll",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
