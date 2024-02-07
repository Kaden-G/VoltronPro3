variable "aws_region" {
  description = "The AWS region in which resources will be created"
  type        = string
  default     = "us-east-1"  // Replace with your default region or remove the default to make it mandatory
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "096280765184" // Replace with your AWS account ID
  // No default provided, this should be supplied by the user
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "Voltron" // Replace with your desired DynamoDB table name
  // No default provided, this should be supplied by the user
}
