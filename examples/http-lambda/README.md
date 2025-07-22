# HTTP API with Lambda Integration Example

This example demonstrates how to create a basic HTTP API Gateway v2 with Lambda integration.

## Features

- HTTP API Gateway v2
- Lambda function integration
- CORS configuration
- CloudWatch logging
- Auto-deployment enabled

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

- **Lambda Function**: A simple Node.js Lambda function that returns JSON responses
- **IAM Role**: Basic execution role for the Lambda function
- **API Gateway v2**: HTTP API with two routes (GET / and POST /data)
- **CloudWatch Log Group**: For API Gateway access logs
- **Lambda Permission**: Allows API Gateway to invoke the Lambda function

## Routes

- `GET /` - Returns a simple JSON response
- `POST /data` - Returns a simple JSON response

## Outputs

After deployment, you'll get:

- API endpoint URL
- Stage invoke URL
- Lambda function ARN
- CloudWatch log group ARN

## Testing

You can test the API using curl:

```bash
# Get the stage invoke URL from terraform output
STAGE_URL=$(terraform output -raw stage_invoke_url)

# Test GET endpoint
curl $STAGE_URL/

# Test POST endpoint
curl -X POST $STAGE_URL/data
```

## Configuration

The example uses the following key configurations:

- **Protocol**: HTTP
- **Stage**: prod
- **Auto-deploy**: true
- **Logging**: Enabled with 7-day retention
- **CORS**: Configured for cross-origin requests
