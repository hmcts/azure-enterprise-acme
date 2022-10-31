terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.22.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  alias           = "control"
}

provider "azuread" {}

data "azurerm_client_config" "core" {}
