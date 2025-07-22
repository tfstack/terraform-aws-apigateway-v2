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

# API Gateway v2 module with HTTP Proxy integration
module "apigateway_v2" {
  source = "../../"

  name          = "example-http-proxy-api"
  protocol_type = "HTTP"
  description   = "Example HTTP API with HTTP_PROXY integration"

  routes = {
    get_users = {
      route_key = "GET /users"
      target    = "http_proxy_integration"
    }
    get_user = {
      route_key = "GET /users/{id}"
      target    = "http_proxy_integration"
    }
    post_user = {
      route_key = "POST /users"
      target    = "http_proxy_integration"
    }
    put_user = {
      route_key = "PUT /users/{id}"
      target    = "http_proxy_integration"
    }
    delete_user = {
      route_key = "DELETE /users/{id}"
      target    = "http_proxy_integration"
    }
  }

  integrations = {
    http_proxy_integration = {
      integration_type     = "HTTP_PROXY"
      integration_method   = "ANY"
      integration_uri      = "https://jsonplaceholder.typicode.com"
      timeout_milliseconds = 29000
      passthrough_behavior = "WHEN_NO_MATCH"
    }
  }

  stage_name  = "prod"
  auto_deploy = true

  enable_logging              = true
  log_group_retention_in_days = 7

  cors_configuration = {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age           = 300
  }

  tags = {
    Environment = "example"
    Project     = "apigateway-v2-http-proxy-demo"
  }
}
