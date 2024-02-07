provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region / Update resource (repository) names if needed
}

resource "aws_ecr_repository" "voltron" {
  name = "voltron-repo"
}

resource "aws_ecr_repository_policy" "voltron" {
  name        = "voltron-policy"
  repository  = aws_ecr_repository.voltron.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ]
    }
  ]
}
EOF
}

# Docker build and push
resource "null_resource" "docker_build" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      eval \$(aws ecr get-login --no-include-email --region ${var.aws_region})
      docker build -t ${aws_ecr_repository.voltron.repository_url}:latest .
      docker push ${aws_ecr_repository.voltron.repository_url}:latest
    EOT
  }
}
