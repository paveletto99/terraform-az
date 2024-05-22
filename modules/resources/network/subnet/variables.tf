variable "subnet_name" {
  description = "Subnet name"
  default     = null
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual network name"
  default     = null
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
  type        = string
}

variable "subnet_cidr_list" {
  description = "The address prefixes to use for the subnet."
  type        = list(string)
}

variable "subnet_srv_endpoints" {
  description = "The list of Service endpoints to associate with the subnet."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for el in var.subnet_srv_endpoints : can(regex("^(Microsoft.AzureActiveDirectory|Microsoft.AzureCosmosDB|Microsoft.ContainerRegistry|Microsoft.EventHub|Microsoft.KeyVault|Microsoft.ServiceBus|Microsoft.Sql|Microsoft.Storage and Microsoft.Web)$", el)) == true
    ])
    error_message = "💥 Please use a value from  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet#service_endpoints"
  }
}
variable "subnet_delegation" {
  description = <<EOD
Configuration delegations on subnet
object({
  name = object({
    name = string,
    actions = list(string)
  })
})
EOD
  type        = map(list(any))
  default     = {}
}
