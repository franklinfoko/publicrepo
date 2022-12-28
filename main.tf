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
    cidr_block                           = "10.0.0.0/16"
    instance_tenancy                     = "default"
    enable_network_address_usage_metrics = false
    enable_dns_hostnames                 = true
    enable_dns_support                   = true

    tags = {
      "Name" = "previtheque_vpc"
    }
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

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.previtheque_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    "Name" = "privatesubnet"
  }
}

# Create security group
resource "aws_security_group" "PrevithequeLBSecurityGroup" {
  name        = "PrevithequeLBSecurityGroup"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.previtheque_vpc.id

  ingress {
    description      = "All"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TCP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "PrevithequeLBSecurityGroup"
  }
}

# Create S3 bucket
resource "aws_s3_bucket" "PrevithequeDevelopLBBucket" {
  bucket = "previthequedeveloplbbucket"

  tags = {
    Name        = "drevithequedeveloplbbucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example1" {
  bucket = aws_s3_bucket.PrevithequeDevelopLBBucket.id
  acl    = "private"
}
# Create ALB
resource "aws_lb" "PrevithequeDevelopLB" {
  name               = "PrevithequeDevelopLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id]
  
 

  tags = {
    "Name" = "develop"
  }
}

# Create target group
resource "aws_alb_target_group" "PrevithequeDevelopTargetGroup" {
  name     = "PrevithequeDevelopTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.previtheque_vpc.id
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/ping"
    port = 80
  }
}

# Create alb listeners