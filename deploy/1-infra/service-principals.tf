data "azurerm_client_config" "current" {
}

resource "azuread_application" "acr_pull_sp" {
  count        = var.should_create_service_principal ? 1 : 0
  display_name = "sp-${var.name}-acr-pull"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_password" "acr_pull_sp" {
  count             = var.should_create_service_principal ? 1 : 0
  display_name      = "rbac"
  application_id    = "/applications/${azuread_application.acr_pull_sp[0].object_id}"
  end_date_relative = "4383h" // valid for 6 months then must be rotated for continued use.
}

resource "azuread_service_principal" "acr_pull_sp" {
  count           = var.should_create_service_principal ? 1 : 0
  client_id       = azuread_application.acr_pull_sp[0].client_id
  account_enabled = true
  owners          = [data.azurerm_client_config.current.object_id]
}

resource "local_sensitive_file" "acr_pull_secret" {
  count    = var.should_create_service_principal ? 1 : 0
  filename = "../../out/acr-pull-secret.sh"
  content = templatefile("./scripts/acr-pull-secret.tftpl.sh", {
    acr_pull_secret_name      = var.acr_pull_secret_name
    acr_name                  = azurerm_container_registry.this.name
    aio_cluster_namespace     = var.aio_cluster_namespace
    acr_pull_sp_client_id     = azuread_service_principal.acr_pull_sp[0].client_id
    acr_pull_sp_client_secret = azuread_application_password.acr_pull_sp[0].value
  })
}