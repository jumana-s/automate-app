resource "aws_kms_key" "tf-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/tf-bucket-key"
  target_key_id = aws_kms_key.tf-bucket-key.key_id
}


resource "aws_s3_bucket" "state" {
  bucket = "tf-statefile-${var.env}-bucket"
}

resource "aws_s3_bucket_versioning" "enable_versioning" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "tf-state-lock" {
  name           = "tf-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
