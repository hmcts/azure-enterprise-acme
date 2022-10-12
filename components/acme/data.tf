data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

data "azuread_group" "platform_operations" {
  provider         = azurerm.control
  display_name     = "DTS Platform Operations"
  security_enabled = true
}

data "azuread_group" "dns_contributor" {
  provider     = azurerm.control
  display_name = "DTS Public DNS Contributor (env:${lower(var.env)})"
}