# main.tf

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Update with your preferred region
}

# IAM User
resource "aws_iam_user" "voltron_user" {
  name = "voltron-user"
}

# IAM Role
resource "aws_iam_role" "voltron_role" {
  name = "voltron-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy
resource "aws_iam_policy" "voltron_policy" {
  name        = "voltron-policy"
  description = "A voltron IAM policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::voltron-bucket/*"  # Replace with your actual S3 Bucket
      }
    ]
  })
}

# Attach the policy to the IAM user
resource "aws_iam_user_policy_attachment" "voltron_user_attachment" {
  user       = aws_iam_user.voltron_user.name
  policy_arn = aws_iam_policy.voltron_policy.arn
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "voltron_role_attachment" {
  role       = aws_iam_role.voltron_role.name
  policy_arn = aws_iam_policy.voltron_policy.arn
}
