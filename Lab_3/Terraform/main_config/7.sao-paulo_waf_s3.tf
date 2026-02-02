# ############################################
# # S3: ALB Access Logs Vault
# ############################################
# data "aws_elb_service_account" "main" {
#   region = var.networks["tokyo"].region
# }

# data "aws_caller_identity" "jae_self01" {}

# resource "aws_s3_bucket" "chewbacca_alb_logs_bucket01" {
#   count  = var.enable_alb_access_logs ? 1 : 0
#   bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.jae_self01.account_id}"

#   force_destroy = true

#   tags = { Name = "${var.project_name}-alb-logs-bucket01" }
# }

# resource "aws_s3_bucket_public_access_block" "chewbacca_alb_logs_pab01" {
#   count  = var.enable_alb_access_logs ? 1 : 0
#   bucket = aws_s3_bucket.chewbacca_alb_logs_bucket01[0].id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_policy" "chewbacca_alb_logs_policy01" {
#   count  = var.enable_alb_access_logs ? 1 : 0
#   bucket = aws_s3_bucket.chewbacca_alb_logs_bucket01[0].id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowELBWriteLogs"
#         Effect = "Allow"
#         Principal = {
#           AWS = data.aws_elb_service_account.main.arn
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.chewbacca_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.jae_self01.account_id}/*"
#       },
#       {
#         Sid       = "DenyInsecureTransport"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:*"
#         Resource = [
#           aws_s3_bucket.chewbacca_alb_logs_bucket01[0].arn,
#           "${aws_s3_bucket.chewbacca_alb_logs_bucket01[0].arn}/*"
#         ]
#         Condition = {
#           Bool = { "aws:SecureTransport" = "false" }
#         }
#       }
#     ]
#   })
# }

# ############################################
# # WAFv2: The Shield Generator
# ############################################

# resource "aws_wafv2_web_acl" "chewbacca_waf01" {

#   count = var.enable_waf ? 1 : 0

#   name  = "${var.project_name}-waf01"
#   scope = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.project_name}-waf01"
#     sampled_requests_enabled   = true
#   }

#   # AWS Managed Common Rule Set (Protection against SQLi, XSS, etc.)
#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project_name}-waf-common"
#       sampled_requests_enabled   = true
#     }
#   }
# }


# ###########################################################
# # WAF Logging (CloudWatch)
# ###########################################################

# resource "aws_cloudwatch_log_group" "chewbacca_waf_log_group01" {

#   count = var.waf_log_destination == "cloudwatch" ? 1 : 0

#   # AWS requires this exact prefix for WAF logging
#   name              = "aws-waf-logs-${var.project_name}-webacl01"
#   retention_in_days = var.waf_log_retention_days

#   tags = {
#     Name = "${var.project_name}-waf-log-group01"
#   }
# }

# resource "aws_wafv2_web_acl_logging_configuration" "chewbacca_waf_logging01" {

#   count = var.enable_waf && var.waf_log_destination == "cloudwatch" ? 1 : 0

#   resource_arn            = aws_wafv2_web_acl.chewbacca_waf01[0].arn
#   log_destination_configs = [aws_cloudwatch_log_group.chewbacca_waf_log_group01[0].arn]

#   # Ensures the WAF exists before trying to attach a log config to it
#   depends_on = [aws_wafv2_web_acl.chewbacca_waf01]
# }

# resource "aws_cloudwatch_log_resource_policy" "waf_logging_policy" {
#   policy_name = "AWSWAF-LOGS-Policy"
#   policy_document = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "delivery.logs.amazonaws.com" }
#       Action    = ["logs:CreateLogStream", "logs:PutLogEvents"]
#       Resource  = "${aws_cloudwatch_log_group.chewbacca_waf_log_group01[0].arn}:*"
#     }]
#   })
# }