output "state_bucket_name" {
  value       = "harish-1685-new-bucket"
  description = "S3 bucket used for Terraform remote state"
}

output "state_lock_table" {
  value       = "my-dynamo-table"
  description = "DynamoDB table used for state locking"
}