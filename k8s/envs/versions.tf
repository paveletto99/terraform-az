# Configure the Azure provider
terraform {
  # backend "azurerm" {
  #   resource_group_name  = "remotestoragerg"
  #   storage_account_name = "remotestatestorage"
  #   container_name       = "statefiles"
  #   key                  = "prod.terraform.tfstate"
  # }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16.1"
    }
  }

  required_version = ">= 1.10.0"
}
