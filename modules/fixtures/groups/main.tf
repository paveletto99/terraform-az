terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }
}
provider "azurerm" {
  features {}
}

module "resource_group" {
  source                = "../../resources/groups"
  resourceGroupName     = var.resourceGroupName
  resourceGroupLocation = var.resourceGroupLocation
  resourceGroupTags     = var.resourceGroupTags
}
