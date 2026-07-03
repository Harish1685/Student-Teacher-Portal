terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "s3" {
  source      = "../modules/s3"
  bucket_name = "harish-1685-new-bucket"
}

module "dynamodb" {
  source       = "../modules/dynamodb"
  table_name   = "my-dynamo-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
}