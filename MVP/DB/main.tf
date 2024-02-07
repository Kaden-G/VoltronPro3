provider "aws" {
  region = "us-east-1"  # e.g., us-west-2
}

resource "aws_dynamodb_table" "Voltron" {
  name           = "Voltron"
  billing_mode   = "PROVISIONED"  # Or "PAY_PER_REQUEST"
  read_capacity  = 5  # Only if using PROVISIONED billing mode
  write_capacity = 5  # Only if using PROVISIONED billing mode
  hash_key       = "clientUsername"
  range_key      = "title"

  attribute {
    name = "clientUsername"
    type = "S"  # String type
  }

  attribute {
    name = "title"
    type = "S"
  }

  

  // Enable DynamoDB Stream
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}
