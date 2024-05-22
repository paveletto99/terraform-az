variable "region" {}
variable "vnet_rg_name" {}
variable "vnet_name" {}
variable "vnet_resource_tags" { type = map(string) }
variable "create_resource_group" {
  description = "Option to create a Azure resource group to use for VNET"
  type        = bool
  default     = false
}
variable "subnets" {
  description = "Map of subnet objects. name, cidr, and service_endpoints supported"
  type = map(object({
    cidr              = list(string)
    service_endpoints = list(string)
  }))
  default = {}
}
variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  type        = list(string)
  default     = ["10.52.0.0/16"]
}
