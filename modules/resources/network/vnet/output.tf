output "az_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "az_vnet" {
  value = azurerm_virtual_network.vnet
}
output "az_subnets" {
  value = azurerm_subnet.subnet[*]
}

locals {
  ids   = [for d in azurerm_subnet.subnet : d.id]
  cidrs = [for d in azurerm_subnet.subnet : d.address_prefixes[0]]
}
# return onlu the first instance on az subnets
# TODO the index must be passed as variable now we get the first subnet as defaulr
output "az_subnet_ids" {
  value = local.ids
}
output "az_subnet_cidrs" {
  value = local.cidrs
}

output "vnet_rg_name" {
  description = "The name of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.netrgrp[*].name, azurerm_resource_group.netrg[*].name, [""]), 0)
}
