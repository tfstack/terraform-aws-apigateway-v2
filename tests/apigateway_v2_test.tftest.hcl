run "http_api_basic" {
  command = plan

  variables {
    name          = "test-http-api"
    protocol_type = "HTTP"
    description   = "Test HTTP API"
    routes = {
      get_users = {
        route_key = "GET /users"
        target    = "lambda_integration"
      }
      post_user = {
        route_key = "POST /users"
        target    = "lambda_integration"
      }
    }
    integrations = {
      lambda_integration = {
        integration_type       = "AWS_PROXY"
        integration_method     = "POST"
        lambda_arn             = "arn:aws:lambda:ap-southeast-2:123456789012:function:test-function"
        payload_format_version = "2.0"
        timeout_milliseconds   = 30000
      }
    }
    stage_name                  = "prod"
    auto_deploy                 = true
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
      Environment = "test"
      Project     = "apigateway-v2-test"
    }
  }

  assert {
    condition     = var.name == "test-http-api"
    error_message = "API name should be test-http-api"
  }

  assert {
    condition     = var.protocol_type == "HTTP"
    error_message = "Protocol type should be HTTP"
  }

  assert {
    condition     = length(var.routes) == 2
    error_message = "Should have 2 routes"
  }

  assert {
    condition     = length(var.integrations) == 1
    error_message = "Should have 1 integration"
  }

  assert {
    condition     = var.stage_name == "prod"
    error_message = "Stage name should be prod"
  }

  assert {
    condition     = var.auto_deploy == true
    error_message = "Auto deploy should be true"
  }

  assert {
    condition     = var.enable_logging == true
    error_message = "Logging should be enabled"
  }

  assert {
    condition     = var.log_group_retention_in_days == 7
    error_message = "Log retention should be 7 days"
  }

  # Test route configurations
  assert {
    condition     = var.routes["get_users"].route_key == "GET /users"
    error_message = "First route key should be GET /users"
  }

  assert {
    condition     = var.routes["post_user"].route_key == "POST /users"
    error_message = "Second route key should be POST /users"
  }

  assert {
    condition     = var.routes["get_users"].target == "lambda_integration"
    error_message = "First route target should be lambda_integration"
  }

  assert {
    condition     = var.routes["post_user"].target == "lambda_integration"
    error_message = "Second route target should be lambda_integration"
  }

  # Test integration configurations
  assert {
    condition     = var.integrations["lambda_integration"].integration_type == "AWS_PROXY"
    error_message = "Integration type should be AWS_PROXY"
  }

  assert {
    condition     = var.integrations["lambda_integration"].integration_method == "POST"
    error_message = "Integration method should be POST"
  }

  assert {
    condition     = var.integrations["lambda_integration"].payload_format_version == "2.0"
    error_message = "Payload format version should be 2.0"
  }

  assert {
    condition     = var.integrations["lambda_integration"].timeout_milliseconds == 30000
    error_message = "Timeout should be 30000 milliseconds"
  }

  # Test CORS configuration
  assert {
    condition     = var.cors_configuration.allow_credentials == false
    error_message = "CORS allow credentials should be false"
  }

  assert {
    condition     = contains(var.cors_configuration.allow_methods, "GET")
    error_message = "CORS should allow GET method"
  }

  assert {
    condition     = contains(var.cors_configuration.allow_methods, "POST")
    error_message = "CORS should allow POST method"
  }

  assert {
    condition     = contains(var.cors_configuration.allow_methods, "OPTIONS")
    error_message = "CORS should allow OPTIONS method"
  }

  assert {
    condition     = var.cors_configuration.max_age == 300
    error_message = "CORS max age should be 300"
  }

  # Test tags
  assert {
    condition     = var.tags.Environment == "test"
    error_message = "Environment tag should be test"
  }

  assert {
    condition     = var.tags.Project == "apigateway-v2-test"
    error_message = "Project tag should be apigateway-v2-test"
  }
}

run "websocket_api_basic" {
  command = plan

  variables {
    name          = "test-websocket-api"
    protocol_type = "WEBSOCKET"
    description   = "Test WebSocket API"
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
        integration_type       = "AWS_PROXY"
        integration_method     = "POST"
        lambda_arn             = "arn:aws:lambda:ap-southeast-2:123456789012:function:websocket-handler"
        payload_format_version = "2.0"
        timeout_milliseconds   = 30000
      }
    }
    stage_name                  = "prod"
    auto_deploy                 = true
    enable_logging              = true
    log_group_retention_in_days = 7
    tags = {
      Environment = "test"
      Project     = "apigateway-v2-websocket-test"
    }
  }

  assert {
    condition     = var.name == "test-websocket-api"
    error_message = "API name should be test-websocket-api"
  }

  assert {
    condition     = var.protocol_type == "WEBSOCKET"
    error_message = "Protocol type should be WEBSOCKET"
  }

  assert {
    condition     = length(var.routes) == 3
    error_message = "Should have 3 routes for WebSocket"
  }

  assert {
    condition     = var.routes["connect"].route_key == "$connect"
    error_message = "Connect route key should be $connect"
  }

  assert {
    condition     = var.routes["disconnect"].route_key == "$disconnect"
    error_message = "Disconnect route key should be $disconnect"
  }

  assert {
    condition     = var.routes["default"].route_key == "$default"
    error_message = "Default route key should be $default"
  }

  assert {
    condition     = var.integrations["websocket_lambda_integration"].integration_type == "AWS_PROXY"
    error_message = "WebSocket integration type should be AWS_PROXY"
  }
}

run "custom_domain_api" {
  command = plan

  variables {
    name          = "test-custom-domain-api"
    protocol_type = "HTTP"
    description   = "Test HTTP API with custom domain"
    routes = {
      get_root = {
        route_key = "GET /"
        target    = "lambda_integration"
      }
    }
    integrations = {
      lambda_integration = {
        integration_type       = "AWS_PROXY"
        integration_method     = "POST"
        lambda_arn             = "arn:aws:lambda:ap-southeast-2:123456789012:function:test-function"
        payload_format_version = "2.0"
        timeout_milliseconds   = 30000
      }
    }
    stage_name                  = "prod"
    auto_deploy                 = true
    enable_domain_name          = true
    domain_name                 = "api.example.com"
    certificate_arn             = "arn:aws:acm:ap-southeast-2:123456789012:certificate/test-cert"
    enable_logging              = true
    log_group_retention_in_days = 7
    tags = {
      Environment = "test"
      Project     = "apigateway-v2-custom-domain-test"
    }
  }

  assert {
    condition     = var.enable_domain_name == true
    error_message = "Domain name should be enabled"
  }

  assert {
    condition     = var.domain_name == "api.example.com"
    error_message = "Domain name should be api.example.com"
  }

  assert {
    condition     = var.certificate_arn == "arn:aws:acm:ap-southeast-2:123456789012:certificate/test-cert"
    error_message = "Certificate ARN should match expected value"
  }
}
