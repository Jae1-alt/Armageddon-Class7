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

output "soa-paulo_s3_bucket_name" {
  description = "Name for Sao-Paulo S3 bucket"
  value       = aws_s3_bucket.sp_local_vault[0].id
}

output "tokyo_s3_bucket_name" {
  description = "Name for Tokyo S3 bucket"
  value       = aws_s3_bucket.audit_vault.id
}

output "cloudfront_dns_name" {
  description = "Domain name for Cloudfront distribution"
  value       = aws_cloudfront_distribution.chewbacca_cf01.domain_name
}


############################################

