resource "azurerm_key_vault" "kv" {
  location                  = var.location
  name                      = "acme${replace(local.name, "-", "")}"
  resource_group_name       = azurerm_resource_group.rg.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
  tags                      = module.tags.common_tags
  enabled_for_deployment    = true
}


module "application_insights" {
  source = "git::https://github.com/hmcts/terraform-module-application-insights?ref=4.x"

  env                 = var.env
  product             = var.product
  name                = var.product
  resource_group_name = azurerm_resource_group.rg.name

  common_tags = module.tags.common_tags
}

moved {
  from = azurerm_application_insights.appinsight
  to   = module.application_insights.azurerm_application_insights.this
}

resource "azurerm_storage_account" "stg" {
  name                            = "acme${replace(local.name, "-", "")}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.acme_storage_account_repl_type
  tags                            = module.tags.common_tags
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
}

resource "azurerm_windows_function_app" "funcapp" {
  name                = "acme${replace(local.name, "-", "")}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.stg.name
  storage_account_access_key = azurerm_storage_account.stg.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  site_config {
    application_insights_connection_string = "InstrumentationKey=${module.application_insights.instrumentation_key};IngestionEndpoint=https://uksouth-0.in.applicationinsights.azure.com/"
    application_stack {
      dotnet_version              = "v8.0"
      use_dotnet_isolated_runtime = false
    }
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled                       = true
    unauthenticated_client_action = "RedirectToLoginPage"
    default_provider              = "AzureActiveDirectory"
    issuer                        = "https://sts.windows.net/531ff96d-0ae9-462a-8d2d-bec7c0b42082/"
    active_directory {
      client_id = data.azuread_application.appreg.client_id
    }
  }
  app_settings = {
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING   = azurerm_storage_account.stg.primary_connection_string
    WEBSITE_CONTENTSHARE                       = "${var.product}-${var.env}"
    WEBSITE_RUN_FROM_PACKAGE                   = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/${local.acme_major_version}/${local.acme_version_no_prefix}.zip"
    FUNCTIONS_WORKER_RUNTIME                   = "dotnet"
    "Acmebot:AzureDns:SubscriptionId"          = var.subscription_id
    "Acmebot:Contacts"                         = "cnp-acme-owner@hmcts.net"
    "Acmebot:Endpoint"                         = "https://acme-v02.api.letsencrypt.org/"
    "Acmebot:VaultBaseUrl"                     = azurerm_key_vault.kv.vault_uri
    "Acmebot:Environment"                      = "AzureCloud"
    "FUNCTIONS_INPROC_NET8_ENABLED"            = 1
  }
  tags = module.tags.common_tags
}

resource "azuread_group_member" "dnszonecontributor" {
  group_object_id  = data.azuread_group.dns_contributor.object_id
  member_object_id = azurerm_windows_function_app.funcapp.identity[0].principal_id
}

resource "azuread_group_member" "dnszonecontributor-groups" {
  for_each         = var.additional_dns_contributor_envs
  group_object_id  = data.azuread_group.dns_contributor_groups[each.key].object_id
  member_object_id = azurerm_windows_function_app.funcapp.identity[0].principal_id
}
