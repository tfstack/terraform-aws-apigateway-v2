# HTTP API with HTTP Proxy Integration Example

This example demonstrates how to create an HTTP API Gateway v2 with HTTP proxy integration to forward requests to an external API.

## Features

- HTTP API Gateway v2
- HTTP proxy integration to external API
- CORS configuration
- CloudWatch logging
- Auto-deployment enabled
- Multiple route patterns

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Clean up resources
terraform destroy
```

## What's Created

- **API Gateway v2**: HTTP API with HTTP proxy integration
- **Routes**: Multiple routes that proxy to jsonplaceholder.typicode.com
- **CloudWatch Log Group**: For API Gateway access logs
- **Integration**: HTTP_PROXY integration type

## Routes

The example creates routes that proxy to [JSONPlaceholder](https://jsonplaceholder.typicode.com/):

- `GET /users` - Proxies to GET <https://jsonplaceholder.typicode.com/users>
- `GET /users/{id}` - Proxies to GET <https://jsonplaceholder.typicode.com/users/{id}>
- `POST /users` - Proxies to POST <https://jsonplaceholder.typicode.com/users>
- `PUT /users/{id}` - Proxies to PUT <https://jsonplaceholder.typicode.com/users/{id}>
- `DELETE /users/{id}` - Proxies to DELETE <https://jsonplaceholder.typicode.com/users/{id}>

## Integration Configuration

```hcl
integrations = {
  http_proxy_integration = {
    integration_type = "HTTP_PROXY"
    integration_method = "ANY"
    integration_uri    = "https://jsonplaceholder.typicode.com"
    payload_format_version = "2.0"
    timeout_milliseconds = 30000
    passthrough_behavior = "WHEN_NO_MATCH"
  }
}
```

## Outputs

After deployment, you'll get:

- API endpoint URL
- Stage invoke URL
- CloudWatch log group ARN

## Testing

You can test the proxy API using curl:

```bash
# Get the stage invoke URL from terraform output
STAGE_URL=$(terraform output -raw stage_invoke_url)

# Test GET users endpoint
curl $STAGE_URL/users

# Test GET specific user endpoint
curl $STAGE_URL/users/1

# Test POST user endpoint
curl -X POST $STAGE_URL/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Test PUT user endpoint
curl -X PUT $STAGE_URL/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com"}'

# Test DELETE user endpoint
curl -X DELETE $STAGE_URL/users/1
```

## Configuration

The example uses the following key configurations:

- **Protocol**: HTTP
- **Integration Type**: HTTP_PROXY
- **Target API**: jsonplaceholder.typicode.com
- **Stage**: prod
- **Auto-deploy**: true
- **Logging**: Enabled with 7-day retention
- **CORS**: Configured for cross-origin requests

## Use Cases

This pattern is useful for:

- Creating API gateways that proxy to existing APIs
- Adding authentication/authorization to external APIs
- Rate limiting and monitoring external API calls
- Creating unified API interfaces
