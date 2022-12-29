
output "alb_hostname_dev" {
    value = aws_alb.PrevithequeDevelopLB.dns_name
}