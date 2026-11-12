variable "subscription_id" {
  description = "Target Azure account Subscription ID"
  type        = string
}

variable "location" {
  description = "Target location"
  type        = string
  default     = "australiaeast"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the cloud project"
  type        = string
  default     = "cost-intelligence"
}

variable "monthly_budget_amount" {
  description = "The monthly budget amount for the subscription"
  type        = number
  default     = 20
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
}