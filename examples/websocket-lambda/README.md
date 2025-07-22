# WebSocket API with Lambda Integration Example

This example demonstrates how to create a WebSocket API Gateway v2 with Lambda integration.

## Features

- WebSocket API Gateway v2
- Lambda function integration for WebSocket handling
- CloudWatch logging
- Auto-deployment enabled
- Support for $connect, $disconnect, and $default routes

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

- **Lambda Function**: A Node.js Lambda function that handles WebSocket events
- **IAM Role**: Basic execution role for the Lambda function
- **API Gateway v2**: WebSocket API with three routes ($connect, $disconnect, $default)
- **CloudWatch Log Group**: For API Gateway access logs
- **Lambda Permission**: Allows API Gateway to invoke the Lambda function

## Routes

- `$connect` - Handles WebSocket connection events
- `$disconnect` - Handles WebSocket disconnection events
- `$default` - Handles all other WebSocket messages

## WebSocket Handler

The Lambda function handles different WebSocket events:

```javascript
exports.handler = async (event) => {
    const { routeKey, requestContext } = event;

    switch (routeKey) {
        case '$connect':
            return { statusCode: 200, body: 'Connected to WebSocket' };
        case '$disconnect':
            return { statusCode: 200, body: 'Disconnected from WebSocket' };
        case '$default':
            return {
                statusCode: 200,
                body: JSON.stringify({
                    message: 'Default route hit',
                    routeKey: routeKey,
                    connectionId: requestContext.connectionId
                })
            };
    }
};
```

## Outputs

After deployment, you'll get:

- API endpoint URL (WebSocket endpoint)
- Stage invoke URL (WSS endpoint)
- Lambda function ARN
- CloudWatch log group ARN

## Testing

You can test the WebSocket API using a WebSocket client or wscat:

```bash
# Install wscat if you don't have it
npm install -g wscat

# Get the WebSocket URL from terraform output
WS_URL=$(terraform output -raw stage_invoke_url)

# Connect to the WebSocket
wscat -c $WS_URL
```

## Configuration

The example uses the following key configurations:

- **Protocol**: WEBSOCKET
- **Stage**: prod
- **Auto-deploy**: true
- **Logging**: Enabled with 7-day retention
- **Routes**: $connect, $disconnect, $default
