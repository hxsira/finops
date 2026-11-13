resource "azurerm_logic_app_workflow" "cost_alerts" {
  name                = "logicapp-${var.project_name}-${var.environment}-001"
  location            = azurerm_resource_group.cost_intelligence.location
  resource_group_name = azurerm_resource_group.cost_intelligence.name

  tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

resource "azurerm_logic_app_trigger_http_request" "budget_alert" {
  name         = "ReceiveBudgetAlert"
  logic_app_id = azurerm_logic_app_workflow.cost_alerts.id
  method       = "POST"
  schema = jsonencode({
    type = "object"
    properties = {
      schemaId = {
        type = "string"
      }
      data = {
        type = "object"
        properties = {
          essentials = {
            type = "object"
          }
          alertContext = {
            type = "object"
          }
        }
      }
    }
  })
}

resource "azurerm_logic_app_action_custom" "summarise_alet" {
  name         = "SummariseBudgeAlert"
  logic_app_id = azurerm_logic_app_workflow.cost_alerts.id
  body = jsonencode({
    type     = "Compose"
    runAfter = {}
    inputs = {
      budget_name    = "@triggerBody()?['data']?['alertContext']?['AlertData']?['BudgetName']"
      threshold_type = "@triggerBody()?['data']?['alertContext']?['AlertData']?['ThresholdType']"
      spent_amount   = "@triggerBody()?['data']?['alertContext']?['AlertData']?['SpentAmount']"
      scope          = "@triggerBody()?['data']?['alertContext']?['AlertData']?['Scope']"
    }
  })
}