locals {
  name                     = replace(lower(data.azurerm_subscription.subscriptionid.display_name), "sharedservices", "sds")
  app_name                 = "acme-${lower(data.azurerm_subscription.subscriptionid.display_name)}"
  acme_major_version       = regex("^(v[0-9]+)", var.acme_version)[0]
  acme_version_no_prefix   = regex("^v(.+)$", var.acme_version)[0]
}
