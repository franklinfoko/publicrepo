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
}