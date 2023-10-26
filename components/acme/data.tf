data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

data "azuread_group" "platform_operations" {
  display_name     = "DTS Platform Operations"
  security_enabled = true
}

data "azuread_group" "dns_contributor" {
  display_name = "DTS Public DNS Contributor (env:${lower(var.env)})"
}

data "azuread_application" "appreg" {
  display_name = "acme-${lower(data.azurerm_subscription.current.display_name)}"
}

data "azurerm_subscription" "subscriptionid" {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

data "azuread_group" "dns_contributor_groups" {
  for_each     = var.additional_dns_contributor_envs
  display_name = "DTS Public DNS Contributor (env:${lower(each.key)})"
}

data "azuread_service_principal" "app_proxy_ga_service_connection" {
  display_name = "DTS Operations Bootstrap GA"
}