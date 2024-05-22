resource "azurerm_resource_group" "resourceGroup" {
  location = var.location
  name     = var.name
  tags     = var.tags
}
