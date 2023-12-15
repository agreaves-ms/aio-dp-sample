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

variable "aio_cluster_namespace" {
  description = "(Optional) The namespace in the Arc Cluster where AIO resources will be installed. (Otherwise, 'aio')"
  type        = string
  default     = "aio"
}

variable "aio_custom_locations_name" {
  description = "(Optional) the AIO Custom Locations resource name. (Otherwise, 'cl-<var.name>-aio')"
  type        = string
  default     = null
}

variable "aio_targets_main_version" {
  description = "(Optional) The version of the Targets that's deployed using AIO. (Otherwise, '1.0.0')"
  type        = string
  default     = "1.0.0"
}

variable "aio_mq_name" {
  description = "(Optional) The AIO MQ Arc Extension name. (Otherwise, 'mq')"
  type        = string
  default     = "mq"
}
