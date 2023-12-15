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

variable "aio_cluster_namespace" {
  description = "(Optional) The namespace in the Arc Cluster where AIO resources will be installed. (Otherwise, 'aio')"
  type        = string
  default     = "aio"
}

variable "acr_pull_secret_name" {
  description = "(Optional) The imagePullSecret Secret name. (Otherwise, 'acr-pull-secret')"
  type        = string
  default     = "acr-pull-secret"
}

variable "should_create_service_principal" {
  description = "(Optional) Should create the Service Principal which will be used by the cluster to pull ACR images. (Otherwise, 'true')"
  type        = bool
  default     = true
}