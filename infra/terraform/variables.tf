variable "cognitive_account_name" {
  description = "Specifies the Cognitive Account name."
  type        = string
}

variable "location" {
  description = "The Azure region where the service bus will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Cognitive Account."
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group. If false, an existing resource group with the specified name will be used."
  type        = bool
  default     = true
}

variable "cognitive_account_kind" {
  description = "Kind of Cognitive Account."
  type        = string
}

variable "cognitive_account_sku_name" {
  description = "SKU of Cognitive Account."
  type        = string
}

variable "cognitive_deployment_name" {
  description = "Specifies the Cognitive Deployment name."
  type        = string
}

variable "cognitive_deployment_sku" {
  description = "SKU of Cognitive Deployment."
  type        = string
  default     = "GlobalStandard"
}

variable "model" {
  description = "Model configuration."
  type = object({
    format  = string
    name    = string
    version = string
  })
}
