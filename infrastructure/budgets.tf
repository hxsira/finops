resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "budget-${var.project_name}-${var.environment}-monthly"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.monthly_budget_amount
  time_grain      = "Monthly"
  time_period {
    start_date = "2026-11-12T00:00:00Z"
  }
  notification {
    enabled        = true
    threshold      = 50
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }
  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}