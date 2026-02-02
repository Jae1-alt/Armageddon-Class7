variable "listener_secret" {
  description = "Shared secret for; If empty, ALB is open to the world."
  type        = string
  default     = ""
}

variable "http_header_name" {
  description = "Shared secret for; If empty, ALB is open to the world."
  type        = string
  default     = "X-Chewbacca-Growl"
}