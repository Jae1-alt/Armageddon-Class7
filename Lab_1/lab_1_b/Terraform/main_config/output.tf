output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.main_vpc.vpc_id
}

output "az_list" {
  description = "A list of available AZ's for the region"
  value       = [for az in module.main_vpc.available_azs : "${az} is available."]
}

output "instance_private_ip" {
  description = "Private IP for creatd instances"
  value       = module.ec2_plus.instance_private_ips
}

output "_1_instance_public_ip" {
  description = "Clickable public IPs for the created instances"
  value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}"]
}

output "_2_initialize_db" {
  description = "Clickable public IPs for the created instances"
  value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/init"]
}

output "_3_add_to_db" {
  description = "Clickable public IPs for the created instances"
  value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/add?note=1st note"]
}

output "_4_retrieve_from_db" {
  description = "Clickable public IPs for the created instances"
  value       = [for ip in module.ec2_plus.instance_public_ips : "http://${ip}/list"]
}

output "instance_public_ip" {
  description = "Instace Public IP for created instances"
  value       = [module.ec2_plus.instance_public_ips]
}

output "instance_id" {
  description = "Instance ID for created instances"
  value       = [module.ec2_plus.instance_ids]
}