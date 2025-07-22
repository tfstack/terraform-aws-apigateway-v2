# HTTP API with Custom Domain Example

This example demonstrates how to create an HTTP API Gateway v2 with a custom domain name using ACM certificates and Route53.

## Features

- HTTP API Gateway v2 with Lambda integration
- Custom domain name configuration
- ACM certificate management
- Route53 DNS configuration
- CloudWatch logging
- Auto-deployment enabled

## Prerequisites

Before running this example, you need:

1. **Route53 Hosted Zone**: A hosted zone for your domain (e.g., example.com)
2. **Domain Name**: A domain name you control (e.g., api.example.com)
3. **AWS Credentials**: Configured with appropriate permissions

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

- **ACM Certificate**: SSL certificate for the custom domain
- **Route53 Records**: DNS records for certificate validation and API endpoint
- **Lambda Function**: A simple Node.js Lambda function
- **IAM Role**: Basic execution role for the Lambda function
- **API Gateway v2**: HTTP API with custom domain
- **CloudWatch Log Group**: For API Gateway access logs
- **Domain Name**: Custom domain name for the API
- **API Mapping**: Maps the API to the custom domain

## Domain Configuration

The example creates:

- ACM certificate for `api.example.com`
- Route53 validation records
- Route53 A record pointing to the API Gateway
- Custom domain name in API Gateway
- API mapping to the custom domain

## Routes

- `GET /` - Returns a simple JSON response with domain info
- `GET /health` - Returns a health check response

## Lambda Handler

The Lambda function includes domain information in responses:

```javascript
exports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: 'Hello from custom domain Lambda!',
            timestamp: new Date().toISOString(),
            domain: event.requestContext.domainName,
            path: event.requestContext.path
        })
    };
};
```

## Outputs

After deployment, you'll get:

- API endpoint URL
- Custom domain name
- Domain name ARN
- Stage invoke URL
- CloudWatch log group ARN

## Testing

You can test the custom domain API using curl:

```bash
# Test the custom domain endpoint
curl https://api.example.com/

# Test the health endpoint
curl https://api.example.com/health
```

## Configuration

The example uses the following key configurations:

- **Protocol**: HTTP
- **Custom Domain**: api.example.com
- **Certificate**: ACM certificate with DNS validation
- **Stage**: prod
- **Auto-deploy**: true
- **Logging**: Enabled with 7-day retention

## DNS Setup

The example automatically:

1. Creates an ACM certificate for your domain
2. Creates Route53 validation records
3. Waits for certificate validation
4. Creates a Route53 A record pointing to the API Gateway
5. Maps the API to the custom domain

## Important Notes

- **Certificate Validation**: The ACM certificate uses DNS validation, which requires access to your Route53 hosted zone
- **Domain Ownership**: You must own the domain and have access to its DNS records
- **Validation Time**: Certificate validation can take 5-30 minutes
- **Costs**: Custom domains incur additional charges

## Troubleshooting

If the custom domain doesn't work:

1. Check that the ACM certificate is validated
2. Verify the Route53 A record is created correctly
3. Ensure the API mapping is configured
4. Check CloudWatch logs for any errors
