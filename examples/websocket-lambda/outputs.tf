output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.apigateway_v2.api_endpoint
}

output "stage_invoke_url" {
  description = "The WebSocket stage invoke URL"
  value       = module.apigateway_v2.stage_invoke_url
}

output "test_commands" {
  description = "Commands to test the WebSocket API"
  value = {
    install_wscat     = "npm install -g wscat"
    connect_websocket = "wscat -c ${module.apigateway_v2.stage_invoke_url}"
    test_message      = "echo '{\"message\":\"Hello WebSocket\"}' | wscat -c ${module.apigateway_v2.stage_invoke_url}"
  }
}

output "wscat_commands" {
  description = "Ready-to-use wscat commands"
  value = {
    install_wscat     = "npm install -g wscat"
    connect_websocket = "wscat -c ${module.apigateway_v2.stage_invoke_url}"
    test_message      = "echo '{\"message\":\"Hello WebSocket\"}' | wscat -c ${module.apigateway_v2.stage_invoke_url}"
  }
}
