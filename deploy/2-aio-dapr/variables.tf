variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "resource_group_name" {
  description = "(Optional) The resource group name where the Azure Arc Cluster resource is located. (Otherwise, 'rg-<var.name>')"
  type        = string
  default     = null
}

variable "arc_cluster_name" {
  description = "(Optional) the Arc Cluster resource name. (Otherwise, 'arc-<var.name>')"
  type        = string
  default     = null
}

variable "aio_custom_locations_name" {
  description = "(Optional) the AIO Custom Locations resource name. (Otherwise, 'cl-<var.name>-aio')"
  type        = string
  default     = null
}

variable "aio_cluster_namespace" {
  description = "(Optional) The namespace in the Arc Cluster where AIO resources will be installed. (Otherwise, 'aio')"
  type        = string
  default     = "aio"
}

variable "aio_mq_frontend_server" {
  description = "(Optional) The AIO MQ Listener frontend service name. (Currently hardcoded in preview)"
  type        = string
  default     = "aio-mq-dmqtt-frontend"
}

variable "aio_mq_frontend_server_port" {
  description = "(Optional) The AIO MQ Listener frontend service name. (Currently hardcoded in preview)"
  type        = string
  default     = "8883"
}

variable "aio_targets_main_version" {
  description = "(Optional) The version of the Targets that's deployed using AIO. (Otherwise, '1.0.0')"
  type        = string
  default     = "1.0.0"
}

variable "dapr_cluster_namespace" {
  description = "(Optional) The namespace to install the Dapr Helm chart. (Otherwise, 'dapr-system')"
  type        = string
  default     = "dapr-system"
}

variable "dapr_chart_repo" {
  description = "(Optional) The Dapr Helm chart repo URI. (Otherwise, 'https://dapr.github.io/helm-charts/')"
  type        = string
  default     = "https://dapr.github.io/helm-charts/"
}

variable "dapr_chart_name" {
  description = "(Optional) The name of the Dapr Helm chart to install. (Otherwise, 'dapr')"
  type        = string
  default     = "dapr"
}

variable "dapr_chart_version" {
  description = "(Optional) The version of the Dapr Helm chart to install. (Otherwise, '1.11')"
  type        = string
  default     = "1.11"
}

variable "aio_dapr_pubsub_component_name" {
  description = "(Optional) The Component Pub/Sub name installed in the cluster. (Otherwise, 'aio-mq-pubsub')"
  type        = string
  default     = "aio-mq-pubsub"
}

variable "aio_dapr_statestore_component_name" {
  description = "(Optional) The State Management Component name installed in the cluster. (Otherwise, 'aio-mq-statestore')"
  type        = string
  default     = "aio-mq-statestore"
}

variable "aio_dapr_component_loglevel" {
  description = "(Optional) The Log Level for the Dapr Components. (Otherwise, 'Info')"
  type        = string
  default     = "Info"
}

variable "should_enable_tls" {
  description = "(Optional) Enables TLS for internal MQTT communication, (Otherwise, 'true')"
  type        = bool
  default     = true
}
