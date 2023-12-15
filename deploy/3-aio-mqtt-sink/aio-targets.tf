locals {
  acrname = "acr${replace(var.name, "-", "")}"
}

resource "azapi_resource" "aio_targets_mqtt_sink" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-ms"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

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
          name = "mqtt-sink-sa"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(file("./manifests/mqtt-sink-sa.tftpl.yaml"))
          }
        },
        {
          name = "mqtt-sink-deployment"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/mqtt-sink-deployment.tftpl.yaml", {
              acr_name          = local.acrname
              mqtt_sink_image   = var.mqtt_sink_image
              mqtt_sink_version = var.mqtt_sink_version
            }))
          },
          dependencies : ["mqtt-sink-sa"]
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
