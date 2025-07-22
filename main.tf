# API Gateway v2 API
resource "aws_apigatewayv2_api" "this" {
  name          = local.api_name
  protocol_type = var.protocol_type
  description   = var.description

  # CORS configuration for HTTP APIs
  dynamic "cors_configuration" {
    for_each = local.cors_enabled ? [var.cors_configuration] : []
    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }

  tags = local.common_tags
}

# CloudWatch Log Group for API Gateway logging
resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_logging ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.log_group_retention_in_days
  skip_destroy      = local.skip_destroy

  tags = local.common_tags
}

# Lambda Integrations
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambda_integrations

  api_id = aws_apigatewayv2_api.this.id

  integration_type     = each.value.integration_type
  integration_method   = each.value.integration_method
  integration_uri      = each.value.lambda_arn
  timeout_milliseconds = each.value.timeout_milliseconds
  passthrough_behavior = each.value.passthrough_behavior

  # Only set payload_format_version for HTTP APIs
  payload_format_version = var.protocol_type == "HTTP" ? each.value.payload_format_version : null

  request_parameters = each.value.request_parameters

  dynamic "response_parameters" {
    for_each = each.value.response_parameters != null ? each.value.response_parameters : []
    content {
      status_code = response_parameters.value.status_code
      mappings    = response_parameters.value.mappings
    }
  }
}

# HTTP Proxy Integrations
resource "aws_apigatewayv2_integration" "http_proxy" {
  for_each = local.http_integrations

  api_id = aws_apigatewayv2_api.this.id

  integration_type     = each.value.integration_type
  integration_method   = each.value.integration_method
  integration_uri      = each.value.integration_uri
  connection_type      = each.value.connection_type
  connection_id        = each.value.connection_id
  timeout_milliseconds = each.value.timeout_milliseconds
  passthrough_behavior = each.value.passthrough_behavior

  request_parameters = each.value.request_parameters

  dynamic "response_parameters" {
    for_each = each.value.response_parameters != null ? each.value.response_parameters : []
    content {
      status_code = response_parameters.value.status_code
      mappings    = response_parameters.value.mappings
    }
  }
}

# Lambda Routes
resource "aws_apigatewayv2_route" "lambda" {
  for_each = {
    for k, v in var.routes : k => v
    if v.target != null && contains(keys(local.lambda_integrations), v.target)
  }

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.value.target].id}"

  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id
  operation_name     = each.value.operation_name
  api_key_required   = each.value.api_key_required
}

# HTTP Proxy Routes
resource "aws_apigatewayv2_route" "http_proxy" {
  for_each = {
    for k, v in var.routes : k => v
    if v.target != null && contains(keys(local.http_integrations), v.target)
  }

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.http_proxy[each.value.target].id}"

  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id
  operation_name     = each.value.operation_name
  api_key_required   = each.value.api_key_required
}

# Default route for Lambda integrations (HTTP APIs only)
resource "aws_apigatewayv2_route" "default_lambda" {
  count = local.is_http && length(var.routes) > 0 && length(local.lambda_integrations) > 0 ? 1 : 0

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[keys(local.lambda_integrations)[0]].id}"
}

# Default route for HTTP Proxy integrations (HTTP APIs only)
resource "aws_apigatewayv2_route" "default_http_proxy" {
  count = local.is_http && length(var.routes) > 0 && length(local.lambda_integrations) == 0 && length(local.http_integrations) > 0 ? 1 : 0

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.http_proxy[keys(local.http_integrations)[0]].id}"
}

# Stage
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = local.stage_name
  auto_deploy = var.auto_deploy

  # Access log settings
  dynamic "access_log_settings" {
    for_each = var.enable_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.this[0].arn
      format = jsonencode({
        requestId          = "$context.requestId"
        ip                 = "$context.identity.sourceIp"
        requestTime        = "$context.requestTime"
        httpMethod         = "$context.httpMethod"
        routeKey           = "$context.routeKey"
        status             = "$context.status"
        protocol           = "$context.protocol"
        responseLength     = "$context.responseLength"
        integrationLatency = "$context.integrationLatency"
        responseLatency    = "$context.responseLatency"
      })
    }
  }

  depends_on = [aws_cloudwatch_log_group.this]

  tags = local.common_tags
}

# Custom Domain Name
resource "aws_apigatewayv2_domain_name" "this" {
  count = local.domain_name_enabled ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.common_tags
}

# API Mapping for Custom Domain
resource "aws_apigatewayv2_api_mapping" "this" {
  count = local.domain_name_enabled ? 1 : 0

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[0].domain_name
  stage       = aws_apigatewayv2_stage.this.name
}

# Lambda permissions for Lambda integrations
resource "aws_lambda_permission" "api_gateway" {
  for_each = local.lambda_integrations

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_arn != null ? each.value.lambda_function_arn : each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
