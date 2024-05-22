variable "naming_prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "TT"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}
variable "region" {
  type        = string
  default     = "westeurope"
  description = "Region to use for Azure resources"
}

variable "rgname" {
  type = string
  validation {
    condition     = (length(var.rgname) <= 90 && length(var.rgname) > 2 && can(regex("[-\\w\\._\\(\\)]+", var.rgname)))
    error_message = "Resource group name may only contain alphanumeric characters, dash, underscores, parentheses and periods."
  }
}



variable "sp_client_id" {
  type = string
}
variable "sp_client_secret" {
  type = string
}






# K8S
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}


