/**
 * # terraform-module-acme-function
 *
 * Terraform module to create a Function App which automates certificate management.
 *
 * 
 */

 resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.product}-${var.env}-rg"
  tags     = module.tags.common_tags
}

resource "azurerm_service_plan" "asp" {
  location            = var.location
  name                = "${var.product}-${var.env}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "Y1"
  tags                = module.tags.common_tags
}
