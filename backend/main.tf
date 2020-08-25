resource "aws_dynamodb_table" "tf_backend_state_lock_table" {
  name             = var.dynamodb_lock_table_name
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "tf_backend_bucket" {
  bucket = var.backend_bucket
  acl    = "private"
  
  lifecycle {
    prevent_destroy = true
  }
}