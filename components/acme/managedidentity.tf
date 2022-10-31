resource "azurerm_role_assignment" "Reader" {
  principal_id         = azurerm_windows_function_app.funcapp.identity[0].principal_id
  role_definition_name = "Reader"
  scope                = azurerm_resource_group.rg.id
}


resource "azurerm_role_assignment" "kvaccess" {
  principal_id         = azurerm_windows_function_app.funcapp.identity[0].principal_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.kv.id
}
resource "azurerm_role_assignment" "kvgroupaccess" {
  principal_id         = data.azuread_group.platform_operations.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.kv.id
}

