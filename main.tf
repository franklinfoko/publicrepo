terraform {
  cloud {
    organization = "franklinfoko"

    workspaces {
        name = "publicrepo"
    }
  }  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}


# create VPC
resource "aws_vpc" "previtheque_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_network_address_usage_metrics = false
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      "Name" = "previtheque_vpc"
    }
}

# Create subnets
resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.previtheque_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "publicsubnet1"
    }
}

resource "aws_subnet" "publicsubnet2" {
    vpc_id = aws_vpc.previtheque_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "publicsubnet2"
    }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id = aws_vpc.previtheque_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    "Name" = "privatesubnet"
  }
}