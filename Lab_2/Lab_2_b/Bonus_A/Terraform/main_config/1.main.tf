
module "main_vpc" {
  source = "../modules/vpc_networking"

  # Metadata
  environment = var.environment
  owner       = var.owner
  tags        = var.tags

  # VPC Core Configuration
  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr
  dns_support  = var.dns_support
  dns_hostname = var.dns_hostname

  # Subnet Maps
  public_subnets_config  = var.public_subnets_config
  private_subnets_config = var.private_subnets_config

  # Gateways & Connectivity
  enable_igw         = var.enable_igw
  enable_nat_gateway = var.enable_nat_gateway
}

module "ec2_plus" {
  source = "../modules/ec2_plus"

  # Common / Metadata
  environment = var.environment
  owner       = var.owner
  tags        = var.tags

  # EC2 Instance Configuration
  instance_count       = var.instance_count
  instance_name        = var.instance_name
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  ami_filters          = var.ami_filters
  user_script          = var.user_script
  get_password         = var.get_password
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  # Networking & VPC
  vpc_id            = module.main_vpc.vpc_id
  subnet_id         = module.main_vpc.private_subnet_id[2]
  public_ip_address = var.public_ip_address

  # Security Groups
  additional_security_group_ids = [aws_security_group.chews_ec2_sg01.id]

  # Key Management
  key_needed = var.key_needed
  key_name   = var.key_name
}

# --- new secuirty group ---
resource "aws_security_group" "chews_ec2_sg01" {
  name        = "${var.sg_name}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = module.main_vpc.vpc_id


  tags = {
    Name = "${var.sg_name}-ec2-sg01"
  }
}


resource "aws_vpc_security_group_egress_rule" "allow_ipv4" {
  # this trigger allows the egress rule(s) creation only if the security group is created
  for_each = var.egress_rules

  security_group_id = aws_security_group.chews_ec2_sg01.id

  from_port   = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port     = each.value.ip_protocol == "-1" ? null : each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${each.key}-sg"
    }
  )
}
