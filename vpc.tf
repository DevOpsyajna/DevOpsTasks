resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  tags      = {
    Name    = "TerraformVPC"
  }
}
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "TerraformIGW"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags   = {
    Name = "LoadBalancerSubnet1"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id      = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags     = {
    Name   = "TerraformRT"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id       = aws_subnet.public_subnet.id
  route_table_id  = aws_route_table.public-route-table.id
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags   = {
    Name = "LoadBalancerSubnet2"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id       = aws_subnet.public_subnet2.id
  route_table_id  = aws_route_table.public-route-table.id
}
 
 

