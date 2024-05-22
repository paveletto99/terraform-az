resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.region
  sku                 = "Standard"
  admin_enabled       = true
  tags                = var.tags
}
