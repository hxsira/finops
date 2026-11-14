data "azurerm_managed_api" "outlook" {
    name = "office365"
    location = azurerm_resource_group.cost_intelligence.location
}

resource "azurerm_api_connection" "outlook" {
    name = "conn-office365-${var.environment}-001"
    resource_group_name = azurerm_resource_group.cost_intelligence.name
    managed_api_id = data.azurerm_managed_api.outlook
    display_name = "Cost Intelligence Outlook Connection"

    tags = {
        environment = var.environment
        project     = var.project_name
        managed_by  = "terraform"
    }
}