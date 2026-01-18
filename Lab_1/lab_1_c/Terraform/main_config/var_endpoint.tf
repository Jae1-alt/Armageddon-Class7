variable "endpoint_services" {
  description = "List of AWS services to create Interface Endpoints for"
  type        = list(string)
  default = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "secretsmanager"
  ]
}