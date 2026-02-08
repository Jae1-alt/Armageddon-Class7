##########################################################################################
# ec2 ouputs

output "instance_ids" {
  description = "IDs for created instances"
  value       = aws_instance.ec2[*].id
}

output "instance_arns" {
  description = "ARN for created instances"
  value       = aws_instance.ec2[*].arn
}

output "instance_public_ips" {
  description = "Public IP for created instances"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP for created instance"
  value       = aws_instance.ec2[*].private_ip
}

output "instance_public_dns" {
  description = "Public DNS for created instance"
  value       = aws_instance.ec2[*].public_dns
}

output "instance_private_dns" {
  description = "Private DNS for created instance"
  value       = aws_instance.ec2[*].private_dns
}

##########################################################################################
# security group outputs

output "security_group_id" {
  description = "Id for created secuirty group"
  value       = aws_security_group.main[*].id
}

output "security_group_arn" {
  description = "ARN for created security group"
  value       = aws_security_group.main[*].arn
}


##########################################################################################
# Ouputs to be used if you require RDP password output

output "windows_password_encrypted" {
  description = "Password for created instance, to be used in rdp"
  value       = aws_instance.ec2[*].password_data
}

output "windows_password_decrypted" {
  description = "Decrypted Password for RDP. Returns a message if Linux or data is not ready."

  value = var.key_needed ? [ # Gate 1: Check if the key even exists
    for instance in aws_instance.ec2[*] : (
      instance.password_data != "" ? nonsensitive( # Gate 2: Check if password_data actually has content (Linux/Initialization check)
        rsadecrypt(instance.password_data, tls_private_key.rsa[0].private_key_pem)
      ) : "No password data available (likely a Linux instance or still booting)"
    )
  ] : null
}