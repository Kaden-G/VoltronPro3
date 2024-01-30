# main.tf

provider "aws" {
  region = "us-east-1"  # Update with your preferred region
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "voltron_api" {
  name        = "voltron-api"
  description = "voltron API Gateway"
}

# Create Resource
resource "aws_api_gateway_resource" "voltron_resource" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  parent_id   = aws_api_gateway_rest_api.voltron_api.root_resource_id
  path_part   = "voltron"
}

# Create HTTP GET Method
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.voltron_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create HTTP POST Method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.voltron_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create Integration (HTTP Proxy) for GET
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.voltron_api.id
  resource_id             = aws_api_gateway_resource.voltron_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://example.com/get-endpoint"  # Replace with your actual GET endpoint
}

# Create Integration (HTTP Proxy) for POST
resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.voltron_api.id
  resource_id             = aws_api_gateway_resource.voltron_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://example.com/post-endpoint"  # Replace with your actual POST endpoint
}

# Deploy the API
resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on      = [aws_api_gateway_integration.get_integration, aws_api_gateway_integration.post_integration]
  rest_api_id     = aws_api_gateway_rest_api.voltron_api.id
  stage_name      = "prod"
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.voltron_deployment.invoke_url
}
