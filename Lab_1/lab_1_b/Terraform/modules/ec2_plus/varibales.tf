
# comman module variables
variable "environment" {
  description = "Environment for Ec2 and other resource."
  type        = string
  default     = "test"
}

variable "owner" {
  description = "Owner for the created resourcess"
  type        = string
  default     = "Jae"
}

##########################################################################################
# EC2 instance configurations
variable "instance_count" {
  description = "The number of instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "The user defined AMI ID for the instance; used if user as specific AMI id "
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.micro"
}

variable "security_group_id" {
  description = "The ID of the security group"
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
  default     = ""
}

variable "public_ip_address" {
  description = "The choice to have ot not have public IP."
  type        = bool
  default     = false
}

variable "ami_filters" {
  description = "Map of filters used by data block to query AMI. Key is the filter name, Value is a list of patterns."
  type        = map(list(string))

  # Defaulr action is to look for Amazon Linux 2023 AMI
  default = {
    name = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
}

variable "user_script" {
  description = "Path of file for user data input."
  type        = string
  default     = null
}

variable "get_password" {
  description = "Boolean to get or not get instance password, for RDP usage"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Instance profile for EC2"
  default = null
}

##########################################################################################
# VPC and Security Group variables

variable "vpc_id" {
  description = "VPC ID where the SG will be created"
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Varibale allowing for the input of custom security groups ids."
  type        = list(string)
  default     = []
}

variable "create_sg" {
  description = "Controls if a Security Group is created for an instance"
  type        = bool
  default     = true
}

variable "sg_name" {
  description = "Name of the created Secuirty Group."
  type        = string
  default     = "Wrong"
}

variable "sg_description" {
  description = "The description for the created security group"
  type        = string
  default     = null
}

variable "ingress_rules" {
  description = "Map of ingress rules.Each object key is rule name."
  type = map(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
    description = optional(string)
  }))

  default = {
    "http" = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = null
    }
  }
}

variable "egress_rules" {
  description = "Map of egress rules. Each object key is a rule name."
  type = map(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
    description = optional(string)
  }))

  default = {
    "all traffic" = {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = null
    }
  }
}
##########################################################################################
# key pair and tls related variables
variable "key_needed" {
  description = "Trigger to create a key."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = null
}
# if no key creation is needed no default key name is made; this allows the using of pre-exisiting keys

##########################################################################################
# tagging variables and locals
variable "tags" {
  description = "Custom Tag values for all resouce ceated."
  type        = map(string)

  default = {}
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}