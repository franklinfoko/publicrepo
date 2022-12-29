# create VPC
resource "aws_vpc" "previtheque_vpc" {
    cidr_block                           = "10.0.0.0/16"
    instance_tenancy                     = "default"
    enable_network_address_usage_metrics = false
    enable_dns_hostnames                 = true
    enable_dns_support                   = true

    tags = {
      "Name" = "previtheque_vpc"
    }
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

# Create internet gateway
resource "aws_internet_gateway" "previtheque-gw" {
  vpc_id = aws_vpc.previtheque_vpc.id
}

# Create subnets
resource "aws_subnet" "publicsubnet1" {
    vpc_id                  = aws_vpc.previtheque_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "eu-west-3a"

    tags = {
      "Name" = "publicsubnet1"
    }
}

resource "aws_subnet" "publicsubnet2" {
    vpc_id                  = aws_vpc.previtheque_vpc.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "eu-west-3b"

    tags = {
      "Name" = "publicsubnet2"
    }
}

resource "aws_subnet" "publicsubnet3" {
    vpc_id                  = aws_vpc.previtheque_vpc.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "eu-west-3c"

    tags = {
      "Name" = "publicsubnet2"
    }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.previtheque_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    "Name" = "privatesubnet"
  }
}