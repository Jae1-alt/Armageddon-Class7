output "vpc_id" {
  description = "AWS id for created VPC."
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "AWS ARN for created VPC"
  value       = aws_vpc.main.arn
}

output "public_subnet_id" {
  description = "id for created public subnets"
  value = [
    for subnet in aws_subnet.public_subnets : subnet.id
  ]
}

output "private_subnet_id" {
  description = "id for created public subnets"
  value = [
    for subnet in aws_subnet.private_subnets : subnet.id
  ]
}

output "nat_eip_id" {
  description = "The id for the created eip."
  value       = one(aws_eip.nat[*].id)
}

output "public_rt_id" {
  description = "The id for the created public route table."
  value       = one(aws_route_table.public[*].id)
}

output "private_rt_id" {
  description = "The id for the created private route table."
  value       = one(aws_route_table.private_nat_access[*].id)
}

output "available_azs" {
  description = "And indexed list of AZ's, by names, for the region"
  value       = data.aws_availability_zones.available.names
}
