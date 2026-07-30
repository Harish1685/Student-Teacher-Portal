
# custom vpc

resource "aws_vpc" "my_vpc" {

  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    name = "my-vpc-production"
  }
  
}

#subnets 

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

# igw (internet gateway)

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name = "internet-gateway-production"
  }
}

# route tables
  
  # public

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_gateway.id
}


}

# route table association for public route

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

