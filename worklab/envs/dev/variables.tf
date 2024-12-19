variable "company" {
  type        = string
  description = "Company name for resource tagging"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "TT"
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 128
}

variable "admin_username" {
  description = "Admin Username"
  type        = string
}
variable "vm_name" {
  description = "VM Name"
  type        = string
}

