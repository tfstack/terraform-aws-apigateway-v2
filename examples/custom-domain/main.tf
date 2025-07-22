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

# ACM Certificate for custom domain
resource "aws_acm_certificate" "api" {
  domain_name       = "api.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "api-example-com-certificate"
  }
}

# Route53 hosted zone (you would typically create this separately)
data "aws_route53_zone" "example" {
  name = "example.com"
}

# Route53 record for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.example.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Lambda function
resource "aws_lambda_function" "example" {
  filename      = "lambda_function.zip"
  function_name = "example-custom-domain-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  tags = {
    Name = "example-custom-domain-lambda"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "example-custom-domain-lambda-role"

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
            message: 'Hello from custom domain Lambda!',
            timestamp: new Date().toISOString(),
            domain: event.requestContext.domainName,
            path: event.requestContext.path
        })
    };
};
EOF
    filename = "index.js"
  }
}

# API Gateway v2 module with custom domain
module "apigateway_v2" {
  source = "../../"

  name          = "example-custom-domain-api"
  protocol_type = "HTTP"
  description   = "Example HTTP API with custom domain"

  routes = {
    get_root = {
      route_key = "GET /"
      target    = "lambda_integration"
    }
    get_health = {
      route_key = "GET /health"
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

  enable_domain_name = true
  domain_name        = "api.example.com"
  certificate_arn    = aws_acm_certificate_validation.api.certificate_arn

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
    Project     = "apigateway-v2-custom-domain-demo"
  }
}

# Route53 record for the API
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = module.apigateway_v2.domain_name
    zone_id                = data.aws_route53_zone.example.zone_id
    evaluate_target_health = true
  }
}
