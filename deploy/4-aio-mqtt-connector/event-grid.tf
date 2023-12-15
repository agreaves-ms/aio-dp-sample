resource "azapi_resource" "mqttbroker_namespace" {
  #  schema_validation_enabled = false

  type      = "Microsoft.EventGrid/namespaces@2023-12-15-preview"
  name      = "mqtt-${var.name}"
  location  = var.location
  parent_id = data.azurerm_resource_group.this.id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      isZoneRedundant     = true
      publicNetworkAccess = "Enabled"
      topicSpacesConfiguration = {
        state = "Enabled"
      }
    }
    sku = {
      name     = "Standard"
      capacity = 1
    }
  })

  response_export_values = ["properties.topicSpacesConfiguration.hostname"]
}

resource "azapi_resource" "mqttbroker_topicspaces" {
  #  schema_validation_enabled = false

  type      = "Microsoft.EventGrid/namespaces/topicSpaces@2023-12-15-preview"
  name      = "aio-mq"
  parent_id = azapi_resource.mqttbroker_namespace.id

  body = jsonencode({
    properties = {
      topicTemplates = ["#"]
    }
  })
}
