output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.main_vpc.vpc_id
}

# # useful SSM Connection String
# output "ssm_login_helper" {
#   description = "Run this command to log into the private instance"
#   value       = "aws ssm start-session --target ${module.ec2_plus.instance_ids[0]}"
# }


############################################


# output "catloving_chewbacca_app_url" {
#   description = "Access the secure application here"
#   value       = "https://${local.chewbacca_fqdn}"
# }

# 2. THE INFRASTRUCTURE: ALB Details
# output "catloving_chewbacca_alb_dns_name" {
#   description = "The raw DNS of the Load Balancer"
#   value       = aws_lb.chewbacca_alb01.dns_name
# }

# output "chewbacca_waf_id" {
#   value = var.enable_waf ? aws_wafv2_web_acl.chewbacca_waf01[0].id : null
# }

# output "cloudfront_distribution_id" {
#   value = aws_cloudfront_distribution.chewbacca_cf01.id
# }
