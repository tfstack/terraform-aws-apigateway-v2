output "api_id" {
  description = "The ID of the API Gateway v2 API"
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "The ARN of the API Gateway v2 API"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "The endpoint of the API Gateway v2 API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_execution_arn" {
  description = "The execution ARN of the API Gateway v2 API"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_invoke_url" {
  description = "The invoke URL of the API Gateway v2 stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "stage_arn" {
  description = "The ARN of the API Gateway v2 stage"
  value       = aws_apigatewayv2_stage.this.arn
}

output "domain_name" {
  description = "The custom domain name (if enabled)"
  value       = var.enable_domain_name ? aws_apigatewayv2_domain_name.this[0].domain_name : null
}

output "domain_name_arn" {
  description = "The ARN of the custom domain name (if enabled)"
  value       = var.enable_domain_name ? aws_apigatewayv2_domain_name.this[0].arn : null
}

output "domain_name_api_mapping_id" {
  description = "The ID of the API mapping for the custom domain (if enabled)"
  value       = var.enable_domain_name ? aws_apigatewayv2_api_mapping.this[0].id : null
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.this[0].arn : null
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group (if logging is enabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.this[0].name : null
}

output "integration_ids" {
  description = "Map of integration IDs"
  value = merge(
    { for k, v in aws_apigatewayv2_integration.lambda : k => v.id },
    { for k, v in aws_apigatewayv2_integration.http_proxy : k => v.id }
  )
}

output "route_ids" {
  description = "Map of route IDs"
  value = merge(
    { for k, v in aws_apigatewayv2_route.lambda : k => v.id },
    { for k, v in aws_apigatewayv2_route.http_proxy : k => v.id }
  )
}
