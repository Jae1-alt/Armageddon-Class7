locals {
  chewbacca_fqdn = "${var.app_subdomain}.${var.domain_name}"
}

data "aws_caller_identity" "chewbacca_self01" {}

data "aws_region" "chewbacca_region01" {}

# Security Group for ALB 
resource "aws_security_group" "chewbacca_alb_sg01" {
  name        = "${var.project_name}-alb-sg01"
  description = "Public ALB security group"
  vpc_id      = module.main_vpc.vpc_id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg01" }
}

# Update existing EC2 SG to accept traffic ONLY from ALB
resource "aws_security_group_rule" "chewbacca_ec2_ingress_from_alb01" {
  type                     = "ingress"
  security_group_id        = aws_security_group.chews_ec2_sg01.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.chewbacca_alb_sg01.id
}


# Application Load Balancer
resource "aws_lb" "chewbacca_alb01" {
  name               = "${var.project_name}-alb01"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.chewbacca_alb_sg01.id]
  subnets            = module.main_vpc.public_subnet_id[*] # aws_subnet.chewbacca_public_subnets[*].id

  # Access Logs Block
  access_logs {
    bucket  = var.enable_alb_access_logs ? aws_s3_bucket.chewbacca_alb_logs_bucket01[0].id : ""
    prefix  = var.alb_access_logs_prefix
    enabled = var.enable_alb_access_logs
  }

  tags = { Name = "${var.project_name}-alb01" }
}


# Target Group + Attachment
############################################
resource "aws_lb_target_group" "chewbacca_tg01" {
  name     = "${var.project_name}-tg01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.main_vpc.vpc_id

  health_check {
    enabled             = true
    path                = "/" # Root path for health check
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "chewbacca_tg_attach01" {
  target_group_arn = aws_lb_target_group.chewbacca_tg01.arn
  target_id        = module.ec2_plus.instance_ids[0] # aws_instance.chewbacca_ec201_private_bonus.id
  port             = 80
}

resource "aws_lb_listener" "chewbacca_https_listener01" {
  load_balancer_arn = aws_lb.chewbacca_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.chewbacca_acm_validation01.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener" "chewbacca_http_listener01" {
  load_balancer_arn = aws_lb.chewbacca_alb01.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied: The Wookiee Roars (No Secret Header)"
      status_code  = "403"
    }
  }
}