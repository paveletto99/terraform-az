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
      version = "~> 3.21.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }

  required_version = ">= 1.2.0"
}
