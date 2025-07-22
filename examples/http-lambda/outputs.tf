output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.apigateway_v2.api_endpoint
}

output "stage_invoke_url" {
  description = "The stage invoke URL"
  value       = module.apigateway_v2.stage_invoke_url
}

output "test_commands" {
  description = "Commands to test the API endpoints"
  value = {
    get_root  = "curl ${module.apigateway_v2.stage_invoke_url}/"
    post_data = "curl -X POST ${module.apigateway_v2.stage_invoke_url}/data"
  }
}

output "curl_commands" {
  description = "Ready-to-use curl commands"
  value = {
    get_root  = "curl ${module.apigateway_v2.stage_invoke_url}/"
    post_data = "curl -X POST ${module.apigateway_v2.stage_invoke_url}/data"
  }
}
