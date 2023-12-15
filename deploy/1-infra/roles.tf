resource "azurerm_role_assignment" "aio_onboard_sp_k8s_extension_contributor" {
  count        = var.should_create_service_principal ? 1 : 0
  scope        = azurerm_container_registry.this.id
  principal_id = azuread_service_principal.acr_pull_sp[0].id

  role_definition_name = "AcrPull"
}
