
data "azurerm_resource_group" "netrgrp" {
  count = var.create_resource_group == true ? 1 : 0
  name  = var.vnet_rg_name
}

resource "azurerm_resource_group" "netrg" {
  count    = var.create_resource_group == true ? 1 : 0
  name     = var.vnet_rg_name
  location = var.region

  tags = merge({ "Name" = format("%s", var.vnet_name) }, var.vnet_resource_tags)
}

#######################################################
#           VNET
#######################################################

resource "azurerm_virtual_network" "vnet" {
  address_space       = var.vnet_address_space
  location            = var.region
  name                = var.vnet_name
  resource_group_name = var.vnet_rg_name

  tags = merge({ "Name" = format("%s", var.vnet_name) }, var.vnet_resource_tags)
}

#######################################################
#           SUBNET
#######################################################
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  depends_on           = [azurerm_virtual_network.vnet]
  address_prefixes     = lookup(each.value, "cidr")
  name                 = each.key
  resource_group_name  = var.create_resource_group ? azurerm_resource_group.netrg[0].name : var.vnet_rg_name
  service_endpoints    = lookup(each.value, "service_endpoints")
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Enforce network policies to allow Private Endpoint to be added to the subnet
  private_endpoint_network_policies_enabled = true
}
