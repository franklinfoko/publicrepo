# Create alb, target group and listener for dev
resource "aws_alb" "PrevithequeDevelopLB" {
  name               = "PrevithequeDevelopLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id, aws_subnet.publicsubnet3.id]
  
  tags = {
    "Name" = "develop"
  }
}

resource "aws_alb_target_group" "PrevithequeDevelopTargetGroup" {
  name     = "PrevithequeDevelopTargetGroup"
  port     = var.app_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_alb.PrevithequeDevelopLB
  ]
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    matcher = "200"
    path = var.health_check_path
    interval = 30
    port = 80
  }
}

resource "aws_alb_listener" "listener_http_dev" {
  load_balancer_arn = aws_alb.PrevithequeDevelopLB.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeDevelopTargetGroup.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "listener_https_dev" {
  load_balancer_arn =  aws_alb.PrevithequeDevelopLB.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = var.certificate_arn_previtheque_dev
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeDevelopTargetGroup.id
    type = "forward"
  }
}


# Create alb and target group for staging
resource "aws_alb" "PrevithequeStagingLB" {
  name               = "PrevithequeStagingLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id, aws_subnet.publicsubnet3.id]
  
  tags = {
    "Name" = "staging"
  }
}

resource "aws_alb_target_group" "PrevithequeSatgingTargetGroup" {
  name     = "PrevithequeSatgingTargetGroup"
  port     = var.app_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_alb.PrevithequeStagingLB
  ]
  stickiness {
    type = "lb_cookie"
  }
   health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    matcher = "200"
    path = var.health_check_path
    interval = 30
    port = 80
  }
}

resource "aws_alb_listener" "listener_http_stage" {
  load_balancer_arn = aws_alb.PrevithequeStagingLB.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeSatgingTargetGroup.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "listener_https_stage" {
  load_balancer_arn = aws_alb.PrevithequeStagingLB.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = var.certificate_arn_previtheque_stage
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeSatgingTargetGroup.id
    type = "forward"
  }
}

# Create alb and target group for prod
resource "aws_alb" "PrevithequeProdLB" {
  name               = "PrevithequeProdLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PrevithequeLBSecurityGroup.id]
  subnets            = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id, aws_subnet.publicsubnet3.id]
  
  tags = {
    "Name" = "prod"
  }
}

resource "aws_alb_target_group" "PrevithequeProdTargetGroup" {
  name     = "PrevithequeProdTargetGroup"
  port     = var.app_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.previtheque_vpc.id

  depends_on = [
    aws_alb.PrevithequeProdLB
  ]
  stickiness {
    type = "lb_cookie"
  }
   health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    protocol = "HTTP"
    matcher = "200"
    path = var.health_check_path
    interval = 30
    port = 80
  }
}

resource "aws_alb_listener" "listener_http_prod" {
  load_balancer_arn = aws_alb.PrevithequeProdLB.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeProdTargetGroup.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "listener_https_prod" {
  load_balancer_arn = aws_alb.PrevithequeProdLB.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = var.certificate_arn_previtheque_prod
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_alb_target_group.PrevithequeProdTargetGroup.id
    type = "forward"
  }
}