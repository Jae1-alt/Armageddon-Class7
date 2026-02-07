
resource "aws_security_group" "rds_sg" {
  name        = "rds-private-sg"
  description = "Isolated security group for RDS"
  vpc_id      = module.main_vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "rds-private-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_from_ec2" {
  security_group_id = aws_security_group.rds_sg.id

  referenced_security_group_id = module.ec2_plus.security_group_id[0]

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
  description = "Inbound only from EC2 Web Tier"
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_all" {
  security_group_id = aws_security_group.rds_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}