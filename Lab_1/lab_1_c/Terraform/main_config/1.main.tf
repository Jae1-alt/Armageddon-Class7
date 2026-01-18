
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
  create_sg                     = var.create_sg
  sg_name                       = var.sg_name
  sg_description                = var.sg_description
  ingress_rules                 = var.ingress_rules
  egress_rules                  = var.egress_rules
  security_group_id             = var.security_group_id
  additional_security_group_ids = var.additional_security_group_ids

  # Key Management
  key_needed = var.key_needed
  key_name   = var.key_name
}

