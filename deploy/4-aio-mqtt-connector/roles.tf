resource "azurerm_role_assignment" "aio_mq_evg_ts_publisher" {
  scope        = azapi_resource.mqttbroker_topicspaces.id
  principal_id = local.aio_mq_principal_id

  role_definition_name = "EventGrid TopicSpaces Publisher"
}