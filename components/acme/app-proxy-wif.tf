# DTS Operations - GA, used by the GA-Prod-Tenant WIF service connection.
resource "azurerm_role_assignment" "app_proxy_wif_certificate_read" {
  count                = (var.product == "cft-platform" && contains(["ptl", "ptlsbox"], var.env)) || (var.product == "sds-platform" && var.env == "ptl") ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "0ec60e03-4262-44ce-abcf-83e2131c9207"
}
