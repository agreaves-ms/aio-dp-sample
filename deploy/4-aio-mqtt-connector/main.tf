data "azurerm_resource_group" "this" {
  name = var.resource_group_name != null ? var.resource_group_name : "rg-${var.name}"
}

data "azapi_resource" "aio_custom_locations" {
  type      = "Microsoft.ExtendedLocation/customLocations@2021-08-31-preview"
  name      = var.aio_custom_locations_name != null ? var.aio_custom_locations_name : "cl-${var.name}-aio"
  parent_id = data.azurerm_resource_group.this.id
}
