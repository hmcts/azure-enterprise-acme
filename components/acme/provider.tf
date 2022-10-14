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
  subscription_id = local.subscriptions[var.subscription].id
  alias           = "acme"
}

provider "azuread" {}

data "azurerm_client_config" "core" {}
