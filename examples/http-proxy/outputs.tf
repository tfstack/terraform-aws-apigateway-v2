output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.apigateway_v2.api_endpoint
}

output "stage_invoke_url" {
  description = "The stage invoke URL"
  value       = module.apigateway_v2.stage_invoke_url
}

output "test_commands" {
  description = "Commands to test the HTTP proxy API endpoints"
  value = {
    get_users   = "curl ${module.apigateway_v2.stage_invoke_url}/users"
    get_user    = "curl ${module.apigateway_v2.stage_invoke_url}/users/1"
    post_user   = "curl -X POST ${module.apigateway_v2.stage_invoke_url}/users -H 'Content-Type: application/json' -d @test-data.json"
    put_user    = "curl -X PUT ${module.apigateway_v2.stage_invoke_url}/users/1 -H 'Content-Type: application/json' -d @test-data.json"
    delete_user = "curl -X DELETE ${module.apigateway_v2.stage_invoke_url}/users/1"
  }
}

output "curl_commands" {
  description = "Ready-to-use curl commands"
  value = {
    get_users   = "curl ${module.apigateway_v2.stage_invoke_url}/users"
    get_user    = "curl ${module.apigateway_v2.stage_invoke_url}/users/1"
    post_user   = "curl -X POST ${module.apigateway_v2.stage_invoke_url}/users -H 'Content-Type: application/json' -d @test-data.json"
    put_user    = "curl -X PUT ${module.apigateway_v2.stage_invoke_url}/users/1 -H 'Content-Type: application/json' -d @test-data.json"
    delete_user = "curl -X DELETE ${module.apigateway_v2.stage_invoke_url}/users/1"
  }
}
