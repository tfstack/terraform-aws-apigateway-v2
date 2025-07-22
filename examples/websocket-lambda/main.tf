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

# Lambda function for WebSocket handling
resource "aws_lambda_function" "websocket_handler" {
  filename      = "websocket_lambda_function.zip"
  function_name = "example-websocket-api-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  tags = {
    Name = "example-websocket-api-lambda"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "example-websocket-lambda-role"

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

# Create WebSocket Lambda function code
data "archive_file" "websocket_lambda_zip" {
  type        = "zip"
  output_path = "websocket_lambda_function.zip"
  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('WebSocket Event:', JSON.stringify(event, null, 2));

    const { routeKey, requestContext } = event;

    switch (routeKey) {
        case '$connect':
            return {
                statusCode: 200,
                body: 'Connected to WebSocket'
            };

        case '$disconnect':
            return {
                statusCode: 200,
                body: 'Disconnected from WebSocket'
            };

        case '$default':
            return {
                statusCode: 200,
                body: JSON.stringify({
                    message: 'Default route hit',
                    routeKey: routeKey,
                    connectionId: requestContext.connectionId
                })
            };

        default:
            return {
                statusCode: 200,
                body: JSON.stringify({
                    message: 'Route handled',
                    routeKey: routeKey,
                    connectionId: requestContext.connectionId
                })
            };
    }
};
EOF
    filename = "index.js"
  }
}

# API Gateway v2 module for WebSocket
module "apigateway_v2" {
  source = "../../"

  name          = "example-websocket-api"
  protocol_type = "WEBSOCKET"
  description   = "Example WebSocket API with Lambda integration"

  routes = {
    connect = {
      route_key = "$connect"
      target    = "websocket_lambda_integration"
    }
    disconnect = {
      route_key = "$disconnect"
      target    = "websocket_lambda_integration"
    }
    default = {
      route_key = "$default"
      target    = "websocket_lambda_integration"
    }
  }

  integrations = {
    websocket_lambda_integration = {
      integration_type     = "AWS_PROXY"
      integration_method   = "POST"
      lambda_arn           = aws_lambda_function.websocket_handler.invoke_arn
      lambda_function_arn  = aws_lambda_function.websocket_handler.arn
      timeout_milliseconds = 29000
    }
  }

  stage_name  = "prod"
  auto_deploy = true

  enable_logging              = true
  log_group_retention_in_days = 7

  tags = {
    Environment = "example"
    Project     = "apigateway-v2-websocket-demo"
  }
}
