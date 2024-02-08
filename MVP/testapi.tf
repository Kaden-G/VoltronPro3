provider "aws" {
  region = "us-east-1" # Choose the appropriate region
}

resource "aws_api_gateway_rest_api" "voltron_api" {
  name        = "voltron-api"
  description = "API Gateway for Voltron"
}
# Define the 'assets' resource
resource "aws_api_gateway_resource" "assets" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  parent_id   = aws_api_gateway_rest_api.voltron_api.root_resource_id
  path_part   = "assets"
}

# Define the GET method on 'assets'
resource "aws_api_gateway_method" "assets_get" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.assets.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration_response" "assets_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = "GET"
  status_code = "200"  # Assuming a 200 OK response from your backend

  response_templates = {
    "application/json" = ""
  }

  # Optional: Set response parameters (headers) if needed
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.assets_get_integration]
}
# Define CORS for 'assets' GET method
resource "aws_api_gateway_method_response" "assets_get_cors" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = "GET"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "assets_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = "GET"
  type        = "HTTP"
  integration_http_method  = "GET"
  uri         = "http://voltron-alb-1464347911.us-east-1.elb.amazonaws.com/assets"
}
# OPTIONS method for 'assets'
resource "aws_api_gateway_method" "assets_options" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.assets.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "assets_options_response" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = aws_api_gateway_method.submit_asset_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "assets_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_integration_response" "assets_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.assets.id
  http_method = aws_api_gateway_method.assets_options.http_method
  status_code = aws_api_gateway_method_response.assets_options_response.status_code


      response_parameters = {
        "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Origin'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
      }
      response_templates = {
        "application/json" = ""
      }
    }
  
resource "aws_api_gateway_resource" "submit_asset" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  parent_id   = aws_api_gateway_rest_api.voltron_api.root_resource_id
  path_part   = "submit_asset"
}

resource "aws_api_gateway_method" "submit_asset_post" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.submit_asset.id
  http_method   = "POST"
  authorization = "NONE"
}
  # Define the method response
resource "aws_api_gateway_method_response"  "method_response_post" {
    rest_api_id = aws_api_gateway_rest_api.voltron_api.id
    resource_id   = aws_api_gateway_resource.submit_asset.id
    http_method = aws_api_gateway_method.submit_asset_post.http_method
    status_code = "200" # Example status code, adjust based on your API's specification

    # Define the response models, if applicable. Example for application/json:
    response_models = {
      "application/json" = "Empty"
    }

    # Define the response parameters
    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
    }

    depends_on = [ aws_api_gateway_method.submit_asset_post ]
  }


resource "aws_api_gateway_integration" "submit_asset_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.submit_asset.id
  http_method = aws_api_gateway_method.submit_asset_post.http_method
  type        = "HTTP_PROXY"
  integration_http_method = "POST"
  uri         = "http://voltron-alb-1464347911.us-east-1.elb.amazonaws.com/submit_asset"
}


resource "aws_api_gateway_method" "submit_asset_options" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.submit_asset.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "submit_asset_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.submit_asset.id
  http_method = aws_api_gateway_method.submit_asset_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.submit_asset.id
  http_method = aws_api_gateway_method.submit_asset_options.http_method
  status_code = "200"
  

  response_models = {
    "application/json" = "Empty"
  }
    response_parameters = {
  "method.response.header.Access-Control-Allow-Methods" = true
  "method.response.header.Access-Control-Allow-Headers" = true
  "method.response.header.Access-Control-Allow-Origin" = true
}
  depends_on = [ aws_api_gateway_integration.submit_asset_options_integration ]
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.submit_asset.id
  http_method = aws_api_gateway_method.submit_asset_options.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
}

# Define the '{clientUsername}' resource
resource "aws_api_gateway_resource" "client_username" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  parent_id   = aws_api_gateway_resource.assets.id
  path_part   = "{clientUsername}"
}

# Define the GET method on '{clientUsername}'
resource "aws_api_gateway_method" "client_username_get" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.client_username.id
  http_method   = "GET"
  authorization = "NONE"
    request_parameters = {
    "method.request.path.clientUsername" = true
  }
}

# Define CORS for '{clientUsername}' GET method
resource "aws_api_gateway_method_response" "client_username_get_cors" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.client_username.id
  http_method = "GET"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "client_username_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.client_username.id
  http_method = "GET"
  type        = "HTTP"
  integration_http_method = "GET"
  uri = "http://voltron-alb-1464347911.us-east-1.elb.amazonaws.com/assets/{clientUsername}"
  request_parameters = {
    "integration.request.path.clientUsername" = "method.request.path.clientUsername"
  }
  depends_on = [aws_api_gateway_method.client_username_get]
 }
# OPTIONS method for '{clientUsername}'
resource "aws_api_gateway_method" "client_username_options" {
  rest_api_id   = aws_api_gateway_rest_api.voltron_api.id
  resource_id   = aws_api_gateway_resource.client_username.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "client_username_options_response" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.client_username.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "client_username_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.client_username.id
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_integration_response" "client_username_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.voltron_api.id
  resource_id = aws_api_gateway_resource.client_username.id
  http_method = "GET" # Ensure this matches the method in `aws_api_gateway_integration`
  status_code = "200"

  # Define response parameters if needed
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id   = "${aws_api_gateway_rest_api.voltron_api.id}"
    stage_name    = "Dev"
  
}
