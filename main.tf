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

# Create alb, target group and listener for dev
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

resource "aws_alb_target_group" "PrevithequeDevelopTargetGroup" {
  name     = "PrevithequeDevelopTargetGroup"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_lb.PrevithequeDevelopLB
  ]
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/ping"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:eu-west-3:641144733479:loadbalancer/app/PrevithequeDevelopLB/0fb2aa1523f94d2d" 
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-3:641144733479:targetgroup/PrevithequeDevelopTargetGroup/e033d0c4dac62c07"
    type             = "forward"
  }
}

resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:eu-west-3:641144733479:loadbalancer/app/PrevithequeDevelopLB/0fb2aa1523f94d2d"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = "arn:aws:acm:eu-west-3:641144733479:certificate/f28702cf-df88-4a36-80f0-42cb725d5e6a"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-3:641144733479:targetgroup/PrevithequeDevelopTargetGroup/e033d0c4dac62c07"
    type = "forward"
  }
}


# Create alb and target group for staging
resource "aws_lb" "PrevithequeStagingLB" {
  name               = "PrevithequeStagingLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id]
  
  tags = {
    "Name" = "staging"
  }
}

resource "aws_alb_target_group" "PrevithequeSatgingTargetGroup" {
  name     = "PrevithequeSatgingTargetGroup"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_lb.PrevithequeStagingLB
  ]
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/ping"
    port = 80
  }
}

# Create alb and target group for prod
resource "aws_lb" "PrevithequeProdLB" {
  name               = "PrevithequeProdLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id]
  
  tags = {
    "Name" = "prod"
  }
}

resource "aws_alb_target_group" "PrevithequeProdTargetGroup" {
  name     = "PrevithequeProdTargetGroup"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_lb.PrevithequeProdLB
  ]
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/ping"
    port = 80
  }
}
# Create alb listeners