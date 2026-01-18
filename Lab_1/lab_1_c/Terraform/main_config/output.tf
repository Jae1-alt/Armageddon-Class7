output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.main_vpc.vpc_id
}

output "az_list" {
  description = "A list of available AZ's for the region"
  value       = [for az in module.main_vpc.available_azs : "${az} is available."]
}

# output "instance_private_ip" {
#   description = "Private IP for creatd instances"
#   value       = module.ec2_plus.instance_private_ips
# }

# output "_1_instance_public_ip" {
#   description = "Clickable public IPs for the created instances"
#   value       = [for ip in module.ec2_plus.instance_public_ips : "http//${ip}"]
# }

# output "_2_initialize_db" {
#   description = "Clickable public IPs for the created instances"
#   value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/init"]
# }

# output "_3_add_to_db" {
#   description = "Clickable public IPs for the created instances"
#   value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/add?note=1st note"]
# }

# output "_4_retrieve_from_db" {
#   description = "Clickable public IPs for the created instances"
#   value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/list"]
# }

# Map of Service Names to Endpoint IDs
output "vpc_interface_endpoint_ids" {
  description = "IDs of the created Interface Endpoints"
  value       = { for service, ep in aws_vpc_endpoint.interface_endpoints : service => ep.id }
}

# This confirms Private DNS is active and providing internal endpoints
output "vpc_endpoint_dns_names" {
  description = "Primary DNS names for the Interface Endpoints"
  value       = { for service, ep in aws_vpc_endpoint.interface_endpoints : service => ep.dns_entry[0].dns_name }
}

output "s3_gateway_id" {
  description = "The ID of the S3 Gateway Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

# 4. Handy SSM Connection String
output "ssm_login_helper" {
  description = "Run this command to log into the private instance"
  value       = "aws ssm start-session --target ${module.ec2_plus.instance_ids[0]}"
}

output "instanc_id" {
  description = "Instace ID(s) for created instances"
  value       = [module.ec2_plus.instance_ids]
}