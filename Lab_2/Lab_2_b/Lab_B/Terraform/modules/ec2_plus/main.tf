resource "aws_instance" "ec2" {
  count = var.instance_count

  # this ami uses an if/else condiiton, if ami_id is not null use it, else use the first data.aws_ami.ami.id
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.ami[0].id
  instance_type               = var.instance_type
  associate_public_ip_address = var.public_ip_address
  key_name                    = var.key_name

  vpc_security_group_ids = concat(
    aws_security_group.main[*].id,     # The Splat [*] handles the empty list safely!
    var.additional_security_group_ids, # A variable for user inputed SGs
  )
  subnet_id = var.subnet_id

  user_data = var.user_script != null ? file("${path.root}/${var.user_script}") : null

  get_password_data = var.get_password

  iam_instance_profile = var.iam_instance_profile

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${var.instance_name}-${count.index + 1}"
    }
  )
}

data "aws_ami" "ami" {
  # Acts as an on/off switch, where If false, count is 0 and no resource is created
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = ["amazon", "self"]

  dynamic "filter" {
    for_each = var.ami_filters
    content {
      name   = filter.key
      values = filter.value
    }
  }
}

resource "aws_security_group" "main" {
  # Acts as an on/off switch, where If false, count is 0 and no resource is created
  count = var.create_sg ? 1 : 0

  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${var.sg_name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  # this trigger allows the ingress rule(s) creation only if the security group is screated
  for_each = var.create_sg ? var.ingress_rules : {}

  security_group_id = aws_security_group.main[0].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
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

resource "aws_vpc_security_group_egress_rule" "allow_ipv4" {
  # this trigger allows the egress rule(s) creation only if the security group is created
  for_each = var.create_sg ? var.egress_rules : {}

  security_group_id = aws_security_group.main[0].id

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


resource "aws_key_pair" "windows_key" {
  count = var.key_needed ? 1 : 0

  key_name   = var.key_name
  public_key = tls_private_key.rsa[0].public_key_openssh # Point this to the public from the tls_private.rsaresource
}

resource "tls_private_key" "rsa" {
  count = var.key_needed ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "foo" {
  count = var.key_needed ? 1 : 0

  content         = tls_private_key.rsa[0].private_key_pem
  filename        = "${path.root}/${var.key_name}.pem"
  file_permission = "0400"
}
