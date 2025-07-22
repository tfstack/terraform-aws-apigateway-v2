# terraform-aws-apigateway-v2

Terraform module for managing AWS API Gateway v2 resources

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_api_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping) | resource |
| [aws_apigatewayv2_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name) | resource |
| [aws_apigatewayv2_integration.http_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_integration.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.default_http_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.default_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.http_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_deploy"></a> [auto\_deploy](#input\_auto\_deploy) | Whether to automatically deploy the stage | `bool` | `true` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the ACM certificate for the custom domain | `string` | `null` | no |
| <a name="input_cors_configuration"></a> [cors\_configuration](#input\_cors\_configuration) | CORS configuration for HTTP APIs | <pre>object({<br/>    allow_credentials = optional(bool, false)<br/>    allow_headers     = optional(list(string), ["*"])<br/>    allow_methods     = optional(list(string), ["*"])<br/>    allow_origins     = optional(list(string), ["*"])<br/>    expose_headers    = optional(list(string), [])<br/>    max_age           = optional(number, 300)<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the API Gateway v2 API | `string` | `null` | no |
| <a name="input_domain_mapping_key"></a> [domain\_mapping\_key](#input\_domain\_mapping\_key) | Mapping key for the domain name | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Custom domain name for the API | `string` | `null` | no |
| <a name="input_enable_domain_name"></a> [enable\_domain\_name](#input\_enable\_domain\_name) | Whether to create a custom domain name | `bool` | `false` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging for the API | `bool` | `false` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | Map of integration configurations | <pre>map(object({<br/>    integration_type       = string<br/>    integration_method     = string<br/>    integration_uri        = optional(string)<br/>    lambda_arn             = optional(string)<br/>    lambda_function_arn    = optional(string)<br/>    payload_format_version = optional(string, "2.0")<br/>    timeout_milliseconds   = optional(number, 29000)<br/>    passthrough_behavior   = optional(string, "WHEN_NO_MATCH")<br/>    connection_type        = optional(string)<br/>    connection_id          = optional(string)<br/>    request_parameters     = optional(map(string))<br/>    response_parameters = optional(list(object({<br/>      status_code = string<br/>      mappings    = map(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_log_group_retention_in_days"></a> [log\_group\_retention\_in\_days](#input\_log\_group\_retention\_in\_days) | Number of days to retain CloudWatch logs | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway v2 API | `string` | n/a | yes |
| <a name="input_protocol_type"></a> [protocol\_type](#input\_protocol\_type) | Protocol type for the API Gateway v2 API. Valid values are HTTP and WEBSOCKET | `string` | `"HTTP"` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of route configurations | <pre>map(object({<br/>    route_key          = string<br/>    authorization_type = optional(string, "NONE")<br/>    authorizer_id      = optional(string)<br/>    target             = optional(string)<br/>    operation_name     = optional(string)<br/>    api_key_required   = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | Whether to skip destroy for CloudWatch log group (useful for testing) | `bool` | `false` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the stage to create | `string` | `"$default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the API Gateway v2 API | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_arn"></a> [api\_arn](#output\_api\_arn) | The ARN of the API Gateway v2 API |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | The endpoint of the API Gateway v2 API |
| <a name="output_api_execution_arn"></a> [api\_execution\_arn](#output\_api\_execution\_arn) | The execution ARN of the API Gateway v2 API |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | The ID of the API Gateway v2 API |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group (if logging is enabled) |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group (if logging is enabled) |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The custom domain name (if enabled) |
| <a name="output_domain_name_api_mapping_id"></a> [domain\_name\_api\_mapping\_id](#output\_domain\_name\_api\_mapping\_id) | The ID of the API mapping for the custom domain (if enabled) |
| <a name="output_domain_name_arn"></a> [domain\_name\_arn](#output\_domain\_name\_arn) | The ARN of the custom domain name (if enabled) |
| <a name="output_integration_ids"></a> [integration\_ids](#output\_integration\_ids) | Map of integration IDs |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of route IDs |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | The ARN of the API Gateway v2 stage |
| <a name="output_stage_invoke_url"></a> [stage\_invoke\_url](#output\_stage\_invoke\_url) | The invoke URL of the API Gateway v2 stage |
<!-- END_TF_DOCS -->
