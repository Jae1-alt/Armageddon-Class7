output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.main_vpc.vpc_id
}

# Map of Service Names to Endpoint IDs
output "vpc_interface_endpoint_ids" {
  description = "IDs of the created Interface Endpoints"
  value       = { for service, ep in aws_vpc_endpoint.interface_endpoints : service => ep.id }
}

# This confirms Private DNS is active and providing internal endpoints
output "vpc_endpoint_dns_names" {
  description = "Primary DNS names for the Interface Endpoints"
  value       = { for service, ep in aws_vpc_endpoint.interface_endpoints : service => ep.dns_entry[0].dns_name }
}

output "s3_gateway_id" {
  description = "The ID of the S3 Gateway Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

# useful SSM Connection String
output "ssm_login_helper" {
  description = "Run this command to log into the private instance"
  value       = "aws ssm start-session --target ${module.ec2_plus.instance_ids[0]}"
}


############################################


output "chewbacca_app_url" {
  description = "Access the secure application here"
  value       = "https://${local.chewbacca_fqdn}"
}

# 2. THE INFRASTRUCTURE: ALB Details
output "chewbacca_alb_dns_name" {
  description = "The raw DNS of the Load Balancer"
  value       = aws_lb.chewbacca_alb01.dns_name
}

# THE SHIELD: Clickable WAF Console Link
output "chewbacca_waf_console_link" {
  description = "View your WAF Shield Generator in AWS"
  value       = "https://${var.aws_region}.console.aws.amazon.com/wafv2/homev2/web-acl/${aws_wafv2_web_acl.chewbacca_waf01[0].name}/${aws_wafv2_web_acl.chewbacca_waf01[0].id}/overview?region=${var.aws_region}"
}

# THE HUD: Clickable CloudWatch Dashboard Link
output "chewbacca_dashboard_link" {
  description = "Your Cockpit HUD (Metrics & 5xx Alarms)"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.chewbacca_dashboard01.dashboard_name}"
}

# TECHNICAL IDENTIFIERS: (Required for CLI verification)
output "chewbacca_target_group_arn" {
  value = aws_lb_target_group.chewbacca_tg01.arn
}

output "chewbacca_acm_cert_arn" {
  value = aws_acm_certificate.chewbacca_acm_cert01.arn
}

output "chewbacca_waf_arn" {
  value = var.enable_waf ? aws_wafv2_web_acl.chewbacca_waf01[0].arn : null
}

# troubleshooting
output "chewbacca_tg_arn" {
  value = aws_lb_target_group.chewbacca_tg01.arn
}

output "s3_bukcet_is" {
  value = aws_s3_bucket.chewbacca_alb_logs_bucket01[0].bucket
}