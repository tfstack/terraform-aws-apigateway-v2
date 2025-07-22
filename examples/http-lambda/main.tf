terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# Lambda function
resource "aws_lambda_function" "example" {
  filename      = "lambda_function.zip"
  function_name = "example-http-api-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  tags = {
    Name = "example-http-api-lambda"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "example-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy attachment for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a simple Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: 'Hello from Lambda!',
            timestamp: new Date().toISOString(),
            event: event
        })
    };
};
EOF
    filename = "index.js"
  }
}

# API Gateway v2 module
module "apigateway_v2" {
  source = "../../"

  name          = "example-http-api"
  protocol_type = "HTTP"
  description   = "Example HTTP API with Lambda integration"

  routes = {
    get_root = {
      route_key = "GET /"
      target    = "lambda_integration"
    }
    post_data = {
      route_key = "POST /data"
      target    = "lambda_integration"
    }
  }

  integrations = {
    lambda_integration = {
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      lambda_arn             = aws_lambda_function.example.invoke_arn
      lambda_function_arn    = aws_lambda_function.example.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 29000
    }
  }

  stage_name  = "prod"
  auto_deploy = true

  enable_logging              = true
  log_group_retention_in_days = 7

  cors_configuration = {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age           = 300
  }

  tags = {
    Environment = "example"
    Project     = "apigateway-v2-demo"
  }
}
