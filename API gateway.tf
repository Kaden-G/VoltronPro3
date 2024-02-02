resource "aws_api_gateway_rest_api" "RestAPI" {
  body = jsonencode({
    openapi = "3.0.1",
    info    = {
      title   = "Voltron",
      version = "1.0",
    },
    paths   = {
      "/path1" = {
        get    = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET",
            payloadFormatVersion = "1.0",
            type                 = "HTTP_PROXY",
            uri                  = "http://localhost:8080",
          },
        },
        post   = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST",
            payloadFormatVersion = "1.0",
            type                 = "HTTP_PROXY",
            uri                  = "http://localhost:8080",
          },
        },
        delete = {
          x-amazon-apigateway-integration = {
            httpMethod           = "DELETE",
            payloadFormatVersion = "1.0",
            type                 = "HTTP_PROXY",
            uri                  = "http://localhost:8080",
          },
        },
      },
    },
  })

  name = "Voltron"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
