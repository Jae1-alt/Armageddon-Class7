
resource "aws_security_group" "vpce_sg" {
  name        = "${var.environment}-vpce-sg"
  vpc_id      = module.main_vpc.vpc_id
  description = "Security group for VPC Interface Endpoints"
}

resource "aws_vpc_security_group_ingress_rule" "vpce_in" {
  security_group_id            = aws_security_group.vpce_sg.id
  referenced_security_group_id = module.ec2_plus.security_group_id[0]
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
