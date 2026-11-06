locals {
  name                   = replace(lower(data.azurerm_subscription.subscriptionid.display_name), "sharedservices", "sds")
  app_name               = "acme-${lower(data.azurerm_subscription.subscriptionid.display_name)}"
  acme_major_version     = regex("^(v[0-9]+)", var.acme_version)[0]
  acme_is_v5             = local.acme_major_version == "v5"
  acme_version_no_prefix = regex("^v(.+)$", var.acme_version)[0]
  acme_package_url       = local.acme_is_v5 ? "https://github.com/polymind-inc/acmebot/releases/download/${var.acme_version}/acmebot.zip" : "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/${local.acme_major_version}/${local.acme_version_no_prefix}.zip"
}
