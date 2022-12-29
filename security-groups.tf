# Create security groups

# alb security group
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
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
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

# security group for ecs: Traffic to ecs cluster should come from the alb
resource "aws_security_group" "previtheque_ecs_sg" {
  name = "previtheque_ecs_sg"
  description = "Allow inbound access from the alb only"
  vpc_id = aws_vpc.previtheque_vpc.id 

  ingress {
    protocol = "tcp"
    from_port = var.app_port
    to_port = var.app_port
    security_groups = [aws_security_group.PrevithequeLBSecurityGroup.id]
  }
}