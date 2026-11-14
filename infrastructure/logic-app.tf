resource "azurerm_logic_app_workflow" "cost_alerts" {
  name                = "logicapp-${var.project_name}-${var.environment}-001"
  location            = azurerm_resource_group.cost_intelligence.location
  resource_group_name = azurerm_resource_group.cost_intelligence.name
  workflow_parameters = {
    "$connections" = jsonencode({
      type         = "object"
      defaultValue = {}
    })
  }
  parameters = {
    "$connections" = jsonencode({
      office365 = {
        connectionId   = azurerm_api_connection.outlook.id
        connectionName = azurerm_api_connection.outlook.name
        id             = data.azurerm_managed_api.outlook.id
      }
    })
  }
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

resource "azurerm_logic_app_action_custom" "summarise_alert" {
  name         = "SummariseBudgetAlert"
  logic_app_id = azurerm_logic_app_workflow.cost_alerts.id
  body = jsonencode({
    type     = "Compose"
    runAfter = {}
    inputs = {
      budget_name       = "@triggerBody()?['data']?['alertContext']?['AlertData']?['BudgetName']"
      threshold_type    = "@triggerBody()?['data']?['alertContext']?['AlertData']?['ThresholdType']"
      budget_amount     = "@triggerBody()?['data']?['alertContext']?['AlertData']?['BudgetAmount']"
      spent_amount      = "@triggerBody()?['data']?['alertContext']?['AlertData']?['SpentAmount']"
      forecasted_amount = "@triggerBody()?['data']?['alertContext']?['AlertData']?['ForecastedTotalForPeriod']"
      currency          = "@triggerBody()?['data']?['alertContext']?['AlertData']?['Currency']"
      scope             = "@triggerBody()?['data']?['alertContext']?['AlertData']?['Scope']"


    }
  })
}

resource "azurerm_logic_app_action_custom" "check_alert_type" {
  name         = "CheckAlertType"
  logic_app_id = azurerm_logic_app_workflow.cost_alerts.id
  body = jsonencode({
    type       = "If"
    expression = "@equals(outputs('SummariseBudgetAlert')?['threshold_type'], 'Forecasted')"
    actions = {
      PrepareForecastMessage = {
        type     = "Compose"
        runAfter = {}
        inputs = {
          alert_type        = "Forecasted"
          budget_name       = "@outputs('SummariseBudgetAlert')?['budget_name']"
          forecasted_amount = "@outputs('SummariseBudgetAlert')?['forecasted_amount']"
          currency          = "@outputs('SummariseBudgetAlert')?['currency']"
        }
      }
    }
    else = {
      actions = {
        PrepareActualMessage = {
          type     = "Compose"
          runAfter = {}
          inputs = {
            alert_type   = "Actual"
            budget_name  = "@outputs('SummariseBudgetAlert')?['budget_name']"
            spent_amount = "@outputs('SummariseBudgetAlert')?['spent_amount']"
            currency     = "@outputs('SummariseBudgetAlert')?['currency']"
          }
        }
      }
    }
    runAfter = {
      SummariseBudgetAlert = ["Succeeded"]
    }
  })
  depends_on = [azurerm_logic_app_action_custom.summarise_alert]
}


resource "azurerm_logic_app_action_custom" "send_budget_email" {
  name         = "SendBudgetEmail"
  logic_app_id = azurerm_logic_app_workflow.cost_alerts.id
  depends_on = [
    azurerm_logic_app_action_custom.check_alert_type
  ]
  body = jsonencode({
    type = "ApiConnection"
    runAfter = {
      CheckAlertType = ["Succeeded"]
    }
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['office365']['connectionId']"
        }
      }
      method = "post"
      path   = "/v2/Mail"
      body = {
        To      = var.alert_email
        Subject = "@concat('Azure Budget Alert -', outputs('SummariseBudgetAlert')?['budget_name'])"
        Body    = <<-HTML
                <H3>Azure Cost Alert</H3>

                <p>
                    Budget:
                    @{outputs('SummariseBudgetAlert')?['budget_name']}
                </p>
                <p>
                    Alert Type:
                    @{outputs('SummariseBudgetAlert')?['threshold_type']}
                </p>
                <p>
                    Budget Amount:
                    @{outputs('SummariseBudgetAlert')?['budget_amount']}
                </p>
                <p>
                    Spent Amount:
                    @{outputs('SummariseBudgetAlert')?['spent_amount']}
                </p>
                <p>
                    Forecasted Amount:
                    @{coalesce(outputs('SummariseBudgetAlert')?['forecasted_amount'], 'Not Supplied')}
                </p>
                HTML
      }
    }
  })
}