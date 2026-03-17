resource "aws_dynamodb_table" "my_table" {

  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key

  attribute {
    name = "LockID"
    type = "S"
  }

  
  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}