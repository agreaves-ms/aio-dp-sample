locals {
  arc_cluster_name = var.arc_cluster_name != null ? var.arc_cluster_name : "arc-${var.name}"

  //noinspection HILUnresolvedReference
  aio_mq_principal_id = jsondecode(data.azapi_resource.aio_mq.output).identity.principalId
}
data "azapi_resource" "aio_mq" {
  type      = "Microsoft.KubernetesConfiguration/extensions@2022-11-01"
  name      = var.aio_mq_name
  parent_id = "${data.azurerm_resource_group.this.id}/providers/Microsoft.Kubernetes/connectedClusters/${local.arc_cluster_name}"

  response_export_values = ["identity.principalId"]
}