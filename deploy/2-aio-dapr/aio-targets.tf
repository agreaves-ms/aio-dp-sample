resource "azapi_resource" "aio_targets_dapr" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-dapr"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  body = jsonencode({
    extendedLocation = {
      name = data.azapi_resource.aio_custom_locations.id
      type = "CustomLocation"
    }

    properties = {
      scope   = var.dapr_cluster_namespace
      version = var.aio_targets_main_version
      components = [
        {
          name = "dapr"
          type = "helm.v3"
          properties = {
            chart = {
              repo    = var.dapr_chart_repo
              name    = var.dapr_chart_name
              version = var.dapr_chart_version
            }
          }
        }
      ]

      topologies = [
        {
          bindings = [
            {
              role     = "helm.v3"
              provider = "providers.target.helm"
              config = {
                inCluster = "true"
              }
            },
          ]
        }
      ]
    }
  })
}

resource "azapi_resource" "aio_targets_dapr_components" {
  schema_validation_enabled = false
  type                      = "Microsoft.IoTOperationsOrchestrator/Targets@2023-10-04-preview"
  name                      = "${var.name}-tgt-dcomp"
  location                  = var.location
  parent_id                 = data.azurerm_resource_group.this.id

  depends_on = [
    azapi_resource.aio_targets_dapr
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
          name = "aio-mq-pubsub"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/aio-mq-pubsub.tftpl.yaml", {
              aio_dapr_pubsub_component_name = var.aio_dapr_pubsub_component_name
              aio_mq_frontend_server         = var.aio_mq_frontend_server
              aio_mq_frontend_server_port    = var.aio_mq_frontend_server_port
              should_enable_tls              = var.should_enable_tls
            }))
          }
        },
        {
          name = "aio-mq-statestore"
          type = "yaml.k8s"
          properties = {
            resource = yamldecode(templatefile("./manifests/aio-mq-statestore.tftpl.yaml", {
              aio_dapr_statestore_component_name = var.aio_dapr_statestore_component_name
              aio_mq_frontend_server             = var.aio_mq_frontend_server
              aio_mq_frontend_server_port        = var.aio_mq_frontend_server_port
              should_enable_tls                  = var.should_enable_tls
            }))
          }
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
