resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "ag-${var.project_name}-${var.environment}-001"
  resource_group_name = azurerm_resource_group.cost_intelligence.name
  short_name          = "cost-alerts"
  location            = "global"
  enabled             = true
  email_receiver {
    name                    = "cloud-engineering"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
  tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}