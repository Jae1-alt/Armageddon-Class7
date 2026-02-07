resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = toset(var.endpoint_services)

  vpc_id            = module.main_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.vpce_sg.id]

  subnet_ids          = module.main_vpc.private_subnet_id
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}-${each.value}-endpoint"
  }
}

# S3 gateway endpoint doesn't use SGs, it uses route tables
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = module.main_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [module.main_vpc.private_rt_id]

  tags = { Name = "${var.environment}-s3-gateway" }
}
