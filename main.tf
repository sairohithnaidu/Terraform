#first internet gateway then Vpc
#internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "timing"
    Terraform = "true"
    Environment = "DEV"
  }
}

#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "timing"
    Terraform = "true"
    Environment = "DEV"
  }
}
#here vpc is attached to internet gateway
#subnets, route table and route table assosiation for public
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "timing-public-subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"    #for private we wont give the cidrblock becz it is private
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "timing-public-route"
    Terraform = "true"
    Environment = "DEV"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
#private subnet route table and assosiation
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "timing-private-subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "timing-private-route"
    Terraform = "true"
    Environment = "DEV"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

#subnets, route table and route table assosiation for DATA BASE
resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.21.0/24"

  tags = {
    Name = "timing-database-subnet"
    Terraform = "true"
    Environment = "DEV"
  }
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "timing-database-route"
    Terraform = "true"
    Environment = "DEV"
  }
}
resource "aws_route_table_association" "database" {
  subnet_id      = aws_subnet.database.id
  route_table_id = aws_route_table.database.id
}

#eip
resource "aws_eip" "NAT" {
  domain   = "vpc"
  tags = {
    Name = "Nat"
  }
}
#NAT GATEWAY
resource "aws_nat_gateway" "GATEWAY" {
  allocation_id = aws_eip.NAT.id
  subnet_id  = aws_subnet.public.id #natgateway hould be in public subnet

  tags = {
    Name = "gw NAT"
  }
}

#we need to create the NAt gateway as route

resource "aws_route" "private" { #here we added the NAT GATEWAY to private route
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.GATEWAY.id
  }

  resource "aws_route" "database" { #here we added the NAT GATEWAY to database route
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.GATEWAY.id
  }