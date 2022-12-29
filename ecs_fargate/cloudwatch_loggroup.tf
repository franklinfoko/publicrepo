

# Set up Cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "previtheque_log_group" {
  name = "/ecs/previthequeapi"
  retention_in_days = 30

  tags = {
    "Name" = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "previtheque_log_stream" {
  name = "previtheque-log-stream"
  log_group_name = aws_cloudwatch_log_group.previtheque_log_group.name
}