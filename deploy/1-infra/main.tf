data "azurerm_resource_group" "this" {
  name = var.resource_group_name != null ? var.resource_group_name : "rg-${var.name}"
}