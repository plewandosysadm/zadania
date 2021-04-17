### CREATE VPC

resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/22"
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}

### CREATE PUBLIC SUBNETS

resource "aws_subnet" "PublicA" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "PublicA"
  }
}

resource "aws_subnet" "PublicB" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "PublicB"
  }
}

### CREATE PRIVATE SUBNETS

resource "aws_subnet" "PrivateA" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "PrivateA"
  }
}

resource "aws_subnet" "PrivateB" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "PrivateB"
  }
}

### CREATE IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

#### CREATE NATGW

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.PublicA.id

  tags = {
    Name = "NATGW"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "natgw" {
  vpc                       = true
  depends_on = [aws_internet_gateway.igw]
}

### ROUTING FOR PRIVATE SUBNETS

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
   tags = {
    Name        = "private-route-table"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "privateA" {
  subnet_id      = aws_subnet.PrivateA.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "privateB" {
  subnet_id      = aws_subnet.PrivateB.id
  route_table_id = aws_route_table.private.id
}

### ROUTING FOR PUBLIC SUBNETS

resource "aws_route_table" "public" {
  vpc_id =  aws_vpc.vpc.id
  tags = {
    Name        = "public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "publicA" {
  subnet_id      =  aws_subnet.PublicA.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "publicB" {
  subnet_id      =  aws_subnet.PublicB.id
  route_table_id = aws_route_table.public.id
}

### ONE DEFAULT SECURITY GROUP

resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All"
  }
  
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All"
  }
}