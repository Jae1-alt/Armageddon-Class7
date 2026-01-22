###########################################################
# WAF Logging (CloudWatch)
###########################################################

resource "aws_cloudwatch_log_group" "chewbacca_waf_log_group01" {

  count = var.waf_log_destination == "cloudwatch" ? 1 : 0

  # AWS requires this exact prefix for WAF logging
  name              = "aws-waf-logs-${var.project_name}-webacl01"
  retention_in_days = var.waf_log_retention_days

  tags = {
    Name = "${var.project_name}-waf-log-group01"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "chewbacca_waf_logging01" {

  count = var.enable_waf && var.waf_log_destination == "cloudwatch" ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.chewbacca_waf01[0].arn
  log_destination_configs = [aws_cloudwatch_log_group.chewbacca_waf_log_group01[0].arn]

  # Ensures the WAF exists before trying to attach a log config to it
  depends_on = [aws_wafv2_web_acl.chewbacca_waf01]
}

resource "aws_cloudwatch_log_resource_policy" "waf_logging_policy" {
  count = var.waf_log_destination == "cloudwatch" ? 1: 0 # will only make this policy if log destination is "cloudwatch"

  policy_name = "AWSWAF-LOGS-Policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource  = "${aws_cloudwatch_log_group.chewbacca_waf_log_group01[0].arn}:*"
    }]
  })
}