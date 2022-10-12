module "acme" {

  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=DTSPO-9746/acme-kv"

  location                       = var.location
  env                            = var.env
  common_tags                    = module.tags.common_tags
  product                        = var.product
  subscription_id                = data.azurerm_client_config.current.subscription_id
  acme_storage_account_repl_type = var.acme_storage_account_repl_type
  # dns_contributor_group_object_id     = data.azuread_group.dns_contributor.object_id
  # platform_operations_group_object_id = data.azuread_group.platform_operations.object_id
}

module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}