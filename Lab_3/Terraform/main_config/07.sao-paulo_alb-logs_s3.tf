############################################
# S3: ALB Access Logs Vault
############################################
data "aws_elb_service_account" "sao-paulo" {
  region = var.networks["sao-paulo"].region
}

data "aws_caller_identity" "jae_self02" {}

resource "aws_s3_bucket" "chewbacca_alb_logs_bucket01_sp" {
  count  = var.enable_alb_access_logs ? 1 : 0
  bucket = "${var.project_name}-${var.networks["sao-paulo"].region}-alb-logs-${data.aws_caller_identity.jae_self02.account_id}"

  force_destroy = true

  tags = { Name = "${var.project_name}-alb-logs-bucket01" }
}

resource "aws_s3_bucket_public_access_block" "chewbacca_alb_logs_pab02" {
  count  = var.enable_alb_access_logs ? 1 : 0
  bucket = aws_s3_bucket.chewbacca_alb_logs_bucket01_sp[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "chewbacca_alb_logs_policy02" {
  count  = var.enable_alb_access_logs ? 1 : 0
  bucket = aws_s3_bucket.chewbacca_alb_logs_bucket01_sp[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowELBWriteLogs"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.sao-paulo.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.chewbacca_alb_logs_bucket01_sp[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.jae_self02.account_id}/*"
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.chewbacca_alb_logs_bucket01_sp[0].arn,
          "${aws_s3_bucket.chewbacca_alb_logs_bucket01_sp[0].arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}
