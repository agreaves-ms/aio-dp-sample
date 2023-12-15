locals {
  acrname = "acr${replace(var.name, "-", "")}"
}

resource "azurerm_container_registry" "this" {
  name                = local.acrname
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Basic"

  identity {
    type = "SystemAssigned"
  }
}