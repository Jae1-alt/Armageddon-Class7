variable "sns_topic_name" {
  type    = string
  default = "lab-db-incidents"
}

variable "sns_topic_display_name" {
  type    = string
  default = "DB Incident Alert"
}

variable "sns_subscriptions" {
  description = "A map of subscriptions to create for the SNS topic"
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {
    "primary_email" = {
      protocol = "email"
      endpoint = "admin@example.com"
    }
  }
}

variable "db_alarms" {
  description = "A map of CloudWatch metric alarms to create"
  type = map(object({
    metric_name         = string
    namespace           = string
    statistic           = string
    comparison_operator = string
    threshold           = number
    period              = number
    evaluation_periods  = number
    description         = string
  }))
  default = {
    "lab-db-connection_failure" = {
      metric_name         = "DBConnectionErrors"
      namespace           = "Lab/RDSApp"
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 3
      period              = 300
      evaluation_periods  = 1
      description         = "Monitors database connection failures"
    }
  }
}