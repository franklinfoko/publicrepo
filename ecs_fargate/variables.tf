


variable "aws_region" {
  default = "eu-west-3"
  description = "Default region to deploy resources"
}
variable "certificate_arn_previtheque_dev" {
  default = "arn:aws:acm:eu-west-3:641144733479:certificate/f28702cf-df88-4a36-80f0-42cb725d5e6a"
  description = "Certificate arn for api.devolop.previtheque.com"
}

variable "certificate_arn_previtheque_stage" {
  default = "arn:aws:acm:eu-west-3:641144733479:certificate/09fc880a-de59-4944-8e47-3e468dc7fb21"
  description = "Certificate arn for api.stage.previtheque.com"
}

variable "certificate_arn_previtheque_prod" {
  default = "arn:aws:acm:eu-west-3:641144733479:certificate/b9e12d1e-69c7-45d2-9309-31c63e9a27a1"
  description = "Certificate arn for api.prod.previtheque.com"
}
variable "ecs_task_execution_role" {
    default = "myEcsTaskExecutionRole"
    description = "ECS task execution role name"
}

variable "app_image" {
    default = "641144733479.dkr.ecr.eu-west-3.amazonaws.com/previtheque:develop"
    description = "docker image to run in this ECS cluster"
}

variable "app_port" {
    default = "80"
    description = "port exposed on the docker image"
}

variable "app_count" {
    default = "3"
    description = "number of docker container to run"
}

variable "health_check_path" {
    default = "/ping"
}

variable "fargate_cpu" {
    default = "1024"
    description = " fargate instance cpu unit 1 vcpu"
}

variable "fargate_memory" {
    default = "2048 "
    description = "fargate instance memory 2GiB"
}