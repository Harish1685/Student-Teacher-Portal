module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
}

module "ec2" {
  source = "./modules/ec2"

  aws_ami_id = data.aws_ami.ubuntu.id
  aws_instance_type = "c7i-flex.large"
  aws_key_name = aws_key_pair.my_key.key_name
  aws_subnet_id = module.vpc.public_subnet_id
  aws_volume_size = 20
  aws_volume_type = "gp3"
  aws_vpc_id = module.vpc.my_vpc_id

}
/*
module "s3" {
  source = "./modules/s3"
  bucket_name = "harish-1685-new-bucket"
}

module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "my-dynamo-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

}

*/