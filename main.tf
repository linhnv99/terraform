terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name"    = "vpc"
    "Project" = var.project_name
  }
}


# Create private subnet 
locals {
  private = ["10.0.4.0/24", "10.0.5.0/24", ]
  public  = ["10.0.6.0/24", "10.0.7.0/24"]
  zone    = ["us-east-1a", "us-east-1b"]
}
resource "aws_subnet" "private_subnet" {
  count = length(local.private)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private[count.index]
  availability_zone = local.zone[count.index]

  tags = {
    "Name"    = "private-subnet_${local.zone[count.index]}"
    "Project" = var.project_name
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  count = length(local.public)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public[count.index]
  availability_zone = local.zone[count.index]

  tags = {
    "Name"    = "public-subnet_${local.zone[count.index]}"
    "Project" = var.project_name
  }
}

# Create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"    = "internet gateway"
    "Project" = var.project_name
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
    "Project" = var.project_name
  }
}

# Create route table for private subnet 
resource "aws_route_table" "private_rtb" {
  count = length(local.zone)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    "Name"    = "private-route-table-${local.zone[count.index]}"
    "Project" = var.project_name
  }
}

# Associate subnet to rtb
resource "aws_route_table_association" "public_subnet_to_public_rtb" {
  count = length(local.public)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_subnet_to_private_rtb" {
  count = length(local.private)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}
