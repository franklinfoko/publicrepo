# Create ecs cluster, ecs task definition and ecs service for dev, stage and prod environment

# dev
resource "aws_ecs_cluster" "PrevithequeClusterDev" {
  name = "PrevithequeClusterDev"
}

data "template_file" "previthequeapp" {
  template = file("./templates/image/images.json")

  vars = {
    app_image = var.app_image
    app_port = var.app_port
    fargate_cpu = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region = var.aws_region
  }
}

resource "aws_ecs_task_definition" "PrevithequeTaskDefinitionDev" {
  family = "PrevithequeTaskDefinitionDev"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.fargate_cpu
  memory = var.fargate_memory
  container_definitions = jsonencode([
    {
      name      = "Api"
      image     = "641144733479.dkr.ecr.eu-west-3.amazonaws.com/previtheque:develop"
      cpu       = 0
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
    },
    {
      name      = "second"
      image     = "service-second"
      cpu       = 0
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

resource "aws_ecs_service" "PrevithequeServiceDev" {
  name = "PrevithequeServiceDev"
  cluster = aws_ecs_cluster.PrevithequeClusterDev.id
  task_definition = aws_ecs_task_definition.PrevithequeTaskDefinitionDev.arn
  desired_count = var.app_count
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.previtheque_ecs_sg.id]
    subnets = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id, aws_subnet.publicsubnet3.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.PrevithequeDevelopTargetGroup.arn
    container_name = "previthequeapp"
    container_port = var.app_port
  }

  depends_on = [
    aws_alb_listener.listener_http_dev, aws_alb_listener.listener_https_dev, aws_iam_role_policy_attachment.ecs_task_execution_role
  ]
}