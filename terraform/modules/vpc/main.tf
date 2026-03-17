
# custom vpc

resource "aws_vpc" "my_vpc" {

  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    name = "my-vpc "
  }
  
}

#subnets 

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

/*
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}
*/
# igw (internet gateway)

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name = "internet_gateway"
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

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# NAT gateway for private

# Elastic ip for NAT gateway
/*
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}


resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    name = "my-nat"
  }
}

# private route table

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
  tags = {
    name = "private-RT"
  }
}

# route table assosiation (private)

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

*/

