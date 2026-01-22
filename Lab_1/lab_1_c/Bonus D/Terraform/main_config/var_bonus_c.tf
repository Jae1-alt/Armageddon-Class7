# variable "manage_route53_in_terraform" {
#   description = "If true, create/manage Route53 hosted zone + records in Terraform."
#   type        = bool
#   default     = true
# }

# variable "route53_hosted_zone_id" {
#   description = "If manage_route53_in_terraform=false, provide existing Hosted Zone ID."
#   type        = string
#   default     = ""
# }

# variable "domain_name" {
#   description = "The root domain"
#   type        = string
#   default     = "topclick.click" 
# }

# variable "app_subdomain" {
#   description = "The subdomain for the app (e.g., 'app' for app.topclick.click)"
#   type        = string
#   default     = "app"
# }