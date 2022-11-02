locals {
  name     = replace(lower(data.azurerm_subscription.subscriptionid.display_name), "sharedservices", "sds")
  app_name = "acme-${lower(data.azurerm_subscription.subscriptionid.display_name)}"
}
