provider "aws" {
  region = "ap-south-1"
}


terraform {
  backend "s3" {
    bucket         = "harish-1685-new-bucket"
    key            = "Student-Teacher-Portal/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "my-dynamo-table"
    encrypt        = true
  }
}

