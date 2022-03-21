
resource "aws_vpc" "prod-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "priv-subnet-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.0.128/26"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.0.64/26"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
}

resource "aws_subnet" "priv-subnet-2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.0.192/26"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"
}
