terraform {
  cloud {
    organization = "franklinfoko"

    workspaces {
        name = "example-workspace"
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

    tags = {
      "Name" = "previtheque_vpc"
    }
}

# Create subnets
resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.previtheque_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
      "Name" = "publicsubnet1"
    }
  
}