locals {
  # Common tags
  common_tags = merge(var.tags, {
    Name = var.name
  })

  # API Gateway v2 API
  api_name = var.name

  # Stage configuration
  stage_name = var.stage_name

  # Domain name configuration
  domain_name_enabled = var.enable_domain_name && var.domain_name != null
  domain_mapping_key  = var.domain_mapping_key != null ? var.domain_mapping_key : var.stage_name

  # Logging configuration
  log_group_name = var.enable_logging ? "/aws/apigateway/${var.name}" : null

  # Skip destroy configuration for CloudWatch log group
  skip_destroy = var.skip_destroy

  # Integration mapping for routes
  lambda_integrations = {
    for k, v in var.integrations : k => v
    if v.integration_type == "AWS_PROXY"
  }

  http_integrations = {
    for k, v in var.integrations : k => v
    if v.integration_type == "HTTP_PROXY"
  }

  # Route and integration mapping
  routes_with_integrations = {
    for route_key, route_config in var.routes : route_key => merge(route_config, {
      integration_id = route_config.target != null ? route_config.target : null
    })
  }

  # Integration resource mapping for route targeting
  integration_resource_map = merge(
    {
      for k, v in local.lambda_integrations : k => "lambda"
    },
    {
      for k, v in local.http_integrations : k => "http_proxy"
    }
  )

  # Route targets with correct integration references
  route_targets = {
    for route_key, route_config in var.routes : route_key => (
      route_config.target != null ? (
        contains(keys(local.lambda_integrations), route_config.target) ?
        "integrations/${route_config.target}" :
        "integrations/${route_config.target}"
      ) : null
    )
  }

  # CORS configuration for HTTP APIs
  cors_enabled = var.protocol_type == "HTTP" && var.cors_configuration != null

  # WebSocket specific configurations
  is_websocket = var.protocol_type == "WEBSOCKET"
  is_http      = var.protocol_type == "HTTP"
}
