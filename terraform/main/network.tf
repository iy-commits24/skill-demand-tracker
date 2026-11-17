resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "sdt-vpc"
  }
}


# Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "sdt-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "sdt-private-b"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "sdt-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "sdt-public-b"
  }
}


# Gateways 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "sdt-igw"
  }
}

resource "aws_eip" "nat_public_a" {
  domain = "vpc"

  tags = {
    Name = "sdt-nat-eip-a"
  }
}

resource "aws_eip" "nat_public_b" {
  domain = "vpc"

  tags = {
    Name = "sdt-nat-eip-b"
  }
}

resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.nat_public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "sdt-nat-a"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.nat_public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "sdt-nat-b"
  }

  depends_on = [aws_internet_gateway.main]
}


# Route tables and routes 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "sdt-rt-public"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_a.id
  }
  tags = {
    Name = "sdt-rt-private-a"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_b.id
  }
  tags = {
    Name = "sdt-rt-private-b"
  }
}


# Route tables subnet association
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
