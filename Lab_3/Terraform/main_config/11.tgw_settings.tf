# =============================================================
# SAO PAULO TGW CONFIG
# =============================================================

# Explanation: Liberdade is São Paulo’s Japanese town—local doctors, local compute, remote data.
resource "aws_ec2_transit_gateway" "liberdade_tgw01" {
  provider    = aws.sao-paulo
  description = "liberdade-tgw01 (Sao Paulo spoke)"
  tags = { Name = "liberdade-tgw01" }
}

# Explanation: Liberdade accepts the corridor from Shinjuku—permissions are explicit, not assumed.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "liberdade_accept_peer01" {
  provider                      = aws.sao-paulo
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
  tags = { Name = "liberdade-accept-peer01" }
}

# Explanation: Liberdade attaches to its VPC—compute can now reach Tokyo legally, through the controlled corridor.
resource "aws_ec2_transit_gateway_vpc_attachment" "liberdade_attach_sp_vpc01" {
  provider           = aws.sao-paulo
  transit_gateway_id = aws_ec2_transit_gateway.liberdade_tgw01.id
  vpc_id             = module.vpc_sao_paulo.vpc_id
  subnet_ids         = module.vpc_sao_paulo.private_subnet_id
  tags = { Name = "liberdade-attach-sp-vpc01" }
}

# =============================================================
# TOKYO TGW CONFIG
# =============================================================

# Explanation: Shinjuku Station is the hub—Tokyo is the data authority.
resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
  description = "shinjuku-tgw01 (Tokyo hub)"
  tags = { Name = "shinjuku-tgw01" }
}

# Explanation: Shinjuku connects to the Tokyo VPC—this is the gate to the medical records vault.
resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
  vpc_id             = module.main_vpc.vpc_id
  subnet_ids         = module.main_vpc.private_subnet_id
  tags = { Name = "shinjuku-attach-tokyo-vpc01" }
}

# Explanation: Shinjuku opens a corridor request to Liberdade—compute may travel, data may not.
resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade_peer01" {
  transit_gateway_id      = aws_ec2_transit_gateway.shinjuku_tgw01.id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.liberdade_tgw01.id # created in Sao Paulo module/state
  tags = { Name = "shinjuku-to-liberdade-peer01" }
}

# =============================================================
# ROUTING INSIDE THE TRANSIT GATEWAYS (The Missing Link)
# =============================================================

# 1. Tell Tokyo TGW: "To reach São Paulo (10.191.0.0/16), go through the Peering Attachment"
resource "aws_ec2_transit_gateway_route" "tokyo_tgw_to_sp" {

  destination_cidr_block         = var.networks["sao-paulo"].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.shinjuku_tgw01.association_default_route_table_id
}

# 2. Tell São Paulo TGW: "To reach Tokyo (10.190.0.0/16), go through the Peering Attachment"
resource "aws_ec2_transit_gateway_route" "sp_tgw_to_tokyo" {
  provider                       = aws.sao-paulo
  destination_cidr_block         = var.networks["tokyo"].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.liberdade_tgw01.association_default_route_table_id
}