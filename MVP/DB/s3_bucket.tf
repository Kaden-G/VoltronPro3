resource "aws_s3_bucket" "VoltronStream1" {
  bucket = "VoltronStream1"
 
}

resource "aws_s3_bucket_acl" "VoltronStream1_acl" {
  bucket = aws_s3_bucket.VoltronStream.id
  acl    = "private"
}



resource "aws_s3_bucket_versioning" "VoltronStream1_versioning" {
  bucket = aws_s3_bucket.VoltronStream.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "VoltronStream1_sse_config" {
  bucket = aws_s3_bucket.VoltronStream.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  // or "aws:kms" based on your requirements
    }
  }
}
