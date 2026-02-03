output "tokyo_vpc_id" {
  description = "ID of the created VPC"
  value       = module.main_vpc.vpc_id
}

output "sao-paulo_vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc_sao_paulo.vpc_id
}

output "tokyo_tgw_id" {
  description = "ID of the created TGW in Tokyo"
  value       = aws_ec2_transit_gateway.shinjuku_tgw01.id
}

output "sao-paulo_tgw_id" {
  description = "ID of the created TGW in Sao Paulo"
  value       = aws_ec2_transit_gateway.liberdade_tgw01.id
}

output "tokyo_rds_endpoint" {
  description = "rds endpoint for DB in tokyo"
  value       = aws_db_instance.mysql_db.address
}


# # useful SSM Connection String
# output "ssm_login_helper" {
#   description = "Run this command to log into the private instance"
#   value       = "aws ssm start-session --target ${module.ec2_plus.instance_ids[0]}"
# }


############################################

