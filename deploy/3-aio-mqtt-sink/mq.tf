data "azapi_resource" "mq" {
  type      = "Microsoft.IoTOperationsMQ/mq@2023-10-04-preview"
  name      = "mq-${var.name}"
  parent_id = data.azurerm_resource_group.this.id
}

data "azapi_resource" "mq_broker" {
  type      = "Microsoft.IoTOperationsMQ/mq/broker@2023-10-04-preview"
  name      = "mq-${var.name}-bk"
  parent_id = data.azapi_resource.mq.id
}

data "azapi_resource" "mq_broker_listener" {
  type      = "Microsoft.IoTOperationsMQ/mq/broker/listener@2023-10-04-preview"
  name      = "${data.azapi_resource.mq_broker.name}-lis"
  parent_id = data.azapi_resource.mq_broker.id
}

resource "azapi_resource" "mq_broker_dapr_az" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsMQ/mq/broker/authorization@2023-10-04-preview"
  name                      = "${data.azapi_resource.mq_broker.name}-daz"
  location                  = var.location
  parent_id                 = data.azapi_resource.mq_broker.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }
    properties = {
      listenerRef = [data.azapi_resource.mq_broker_listener.name]
      authorizationPolicies = {
        enableCache = false
        rules = [
          {
            principals = {
              attributes = [
                {
                  group = "mqtt-sink"
                }
              ]
            }
            brokerResources = [
              { method = "Connect" },
              {
                method = "Publish"
                topics = ["sink/data/#"]
              },
              {
                method = "Subscribe"
                topics = ["aio/data/#"]
              }
            ]
          }
        ]
      }
    }
  })
}