
# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name"    = "vpc"
    "Environment" = var.environment
  }
}

# Create private subnet 
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.zones[count.index]

  tags = {
    "Name"    = "private-subnet_${var.zones[count.index]}"
    "Environment" = var.environment
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.zones[count.index]

  tags = {
    "Name"    = "public-subnet_${var.zones[count.index]}"
    "Environment" = var.environment
  }
}

# Create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"    = "internet gateway"
    "Environment" = var.environment
  }
}

# Create route table for public subnet 
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name"    = "public-route-table"
    "Environment" = var.environment
  }
}

# Create route table for private subnet 
resource "aws_route_table" "private_rtb" {
  count = length(var.zones)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    "Name"    = "private-route-table-${var.zones[count.index]}"
    "Environment" = var.environment
  }
}

# Associate subnet to rtb
resource "aws_route_table_association" "public_subnet_to_public_rtb" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rtb.id
}


resource "aws_route_table_association" "private_subnet_to_private_rtb" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rtb[each.key].id
}
