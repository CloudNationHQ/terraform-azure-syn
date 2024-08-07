variable "workspace" {
  description = "describes the synapse workspace configuration"
  type        = any
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region and can be used if location is not specified inside the object."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "default resource group and can be used if resource_group is not specified inside the object."
  type        = string
  default     = null
}