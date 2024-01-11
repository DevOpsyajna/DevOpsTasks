provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIASI4JF6G2XCFBMGHZ"
  secret_key = "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"
}

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
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags   = {
    Name = "LoadBalancerSubnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags   = {
    Name = "LoadBalancerSubnet2"
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

resource "aws_route_table_association" "public-subnet-route-table-association1" {
  subnet_id       = aws_subnet.public_subnet.id
  route_table_id  = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association2" {
  subnet_id       = aws_subnet.public_subnet2.id
  route_table_id  = aws_route_table.public-route-table.id
}

resource "aws_security_group" "SGloadBalancer" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec21" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  user_data              = file("shell.sh")
  vpc_security_group_ids = [aws_security_group.SGloadBalancer.id]
  tags = {
    Name = "LBec21"
  }
}

resource "aws_instance" "ec22" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet2.id
  user_data              = file("shell.sh")
  vpc_security_group_ids = [aws_security_group.SGloadBalancer.id]
  tags = {
    Name = "LBec22"
  }
}

resource "aws_lb_target_group" "targetGroup" {
  health_check {
    interval            = "10"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
  }
  name        = "target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application-loadBalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.targetGroup.arn
    type             = "forward"
  }
}

resource "aws_lb" "application-loadBalancer" {
  name                     = "aws-alb"
  internal                 = false
  ip_address_type          = "ipv4"
  load_balancer_type       = "application"
  security_groups          = [aws_security_group.SGloadBalancer.id]
  subnets = [aws_subnet.public_subnet.id,aws_subnet.public_subnet2.id]
  tags = {
    Name = "aws-alb"
  }
}

resource "aws_lb_target_group_attachment" "tg-attach1" {
  target_group_arn = aws_lb_target_group.targetGroup.arn
  target_id        = aws_instance.ec21.id
}

resource "aws_lb_target_group_attachment" "tg-attach2" {
  target_group_arn = aws_lb_target_group.targetGroup.arn
  target_id        = aws_instance.ec22.id
}

resource "aws_dynamodb_table" "myTable" {
  name             = "YajnaNarayana"
  billing_mode     = "PROVISIONED"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "yajna@123"
  attribute {
    name = "yajna@123"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  lifecycle {
    ignore_changes = [
      ttl
    ]
  }
  
  tags = {
    Name    = "dynamodb-table"
  }
}
