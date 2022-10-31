resource "azuread_group_member" "dnszonecontributor" {
  group_object_id  = var.dns_contributor_group_object_id
  member_object_id = azurerm_windows_function_app.funcapp.identity[0].principal_id
}