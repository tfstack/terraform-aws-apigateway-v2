output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.apigateway_v2.api_endpoint
}

output "stage_invoke_url" {
  description = "The stage invoke URL"
  value       = module.apigateway_v2.stage_invoke_url
}

output "domain_name" {
  description = "The custom domain name"
  value       = module.apigateway_v2.domain_name
}

output "test_commands" {
  description = "Commands to test the custom domain API endpoints"
  value = {
    test_domain       = "curl https://${module.apigateway_v2.domain_name}/"
    test_health       = "curl https://${module.apigateway_v2.domain_name}/health"
    test_stage_url    = "curl ${module.apigateway_v2.stage_invoke_url}/"
    test_stage_health = "curl ${module.apigateway_v2.stage_invoke_url}/health"
  }
}

output "curl_commands" {
  description = "Ready-to-use curl commands"
  value = {
    test_domain       = "curl https://${module.apigateway_v2.domain_name}/"
    test_health       = "curl https://${module.apigateway_v2.domain_name}/health"
    test_stage_url    = "curl ${module.apigateway_v2.stage_invoke_url}/"
    test_stage_health = "curl ${module.apigateway_v2.stage_invoke_url}/health"
  }
}
