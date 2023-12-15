resource "azapi_resource" "aio_targets_mqtt_connector" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-mcon"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azurerm_role_assignment.aio_mq_evg_ts_publisher
  ]

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      scope   = var.aio_cluster_namespace
      version = var.aio_targets_main_version
      components = [
        {
          name = "mqtt-bridge-topic"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(file("./manifests/mqtt-bridge-topic-map.tftpl.yaml"))
          }
        },
        {
          name = "mqtt-bridge-connector"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/mqtt-bridge-connector.tftpl.yaml", {
              //noinspection HILUnresolvedReference
              evgn_ts_hostname = jsondecode(azapi_resource.mqttbroker_namespace.output).properties.topicSpacesConfiguration.hostname
            }))
          },
        }
      ]

      topologies = [
        {
          bindings = [
            {
              role : "yaml.k8s",
              provider : "providers.target.kubectl",
              config : {
                inCluster : "true"
              }
            }
          ]
        }
      ]
    }
  })
}
