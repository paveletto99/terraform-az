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


