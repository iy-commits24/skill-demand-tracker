output "alb_dns_url" {
  description = "URL for reaching the fastapi app through the ALB"
  value       = "http://${aws_lb.alb.dns_name}"
}
