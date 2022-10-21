module "acme" {

  source = "git::https://github.com/hmcts/terraform-module-acme-function.git?ref=master"

  location                       = var.location
  env                            = var.env
  common_tags                    = module.tags.common_tags
  product                        = var.product
  subscription_id                = data.azurerm_client_config.current.subscription_id
  acme_storage_account_repl_type = var.acme_storage_account_repl_type
  application_id                 = data.azuread_application.appreg.application_id

}

module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}