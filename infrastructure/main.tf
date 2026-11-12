resource "azurerm_resource_group" "cost_intelligence" {
  name     = "rg-${var.project_name}-${var.environment}-aue-001"
  location = var.location
}