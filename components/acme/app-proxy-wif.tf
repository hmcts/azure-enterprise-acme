# DTS Operations - GA, used by the GA-Prod-Tenant WIF service connection.
resource "azurerm_role_assignment" "app_proxy_wif_certificate_read" {
  count                = contains(["ptl", "ptlsbox"], var.env) && contains(["cft-platform", "sds-platform"], var.product) ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "0ec60e03-4262-44ce-abcf-83e2131c9207"
}
