terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.71"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
    }
  }
}

provider "azurerm" {
  features {}
}
