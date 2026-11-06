mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000001"
      tenant_id       = "00000000-0000-0000-0000-000000000002"
    }
  }

  mock_data "azurerm_subscription" {
    defaults = {
      display_name = "DTS-SHAREDSERVICES-SBOX"
    }
  }
}

mock_provider "azuread" {
  mock_data "azuread_group" {
    defaults = {
      object_id = "00000000-0000-0000-0000-000000000003"
    }
  }

  mock_data "azuread_application" {
    defaults = {
      client_id = "00000000-0000-0000-0000-000000000004"
    }
  }
}

override_module {
  target = module.application_insights
  outputs = {
    instrumentation_key = "00000000-0000-0000-0000-000000000005"
  }
}

variables {
  env       = "sbox"
  product   = "sds-platform"
  builtFrom = "hmcts/azure-enterprise-acme"
}

run "default_v4_runtime" {
  command = plan

  assert {
    condition = (
      azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].dotnet_version == "v8.0" &&
      !azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].use_dotnet_isolated_runtime &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_WORKER_RUNTIME"] == "dotnet" &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_INPROC_NET8_ENABLED"] == "1" &&
      azurerm_windows_function_app.funcapp.app_settings["Acmebot:Endpoint"] == "https://acme-v02.api.letsencrypt.org/" &&
      !contains(keys(azurerm_windows_function_app.funcapp.app_settings), "FUNCTIONS_EXTENSION_VERSION") &&
      output.package_url == "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/4.3.1.zip"
    )
    error_message = "The default version must preserve the v4 package and .NET 8 in-process configuration."
  }
}

run "v5_runtime" {
  command = plan

  variables {
    acme_version = "v5.1.5"
  }

  assert {
    condition = (
      azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].dotnet_version == "v10.0" &&
      azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].use_dotnet_isolated_runtime &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_WORKER_RUNTIME"] == "dotnet-isolated" &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_EXTENSION_VERSION"] == "~4" &&
      azurerm_windows_function_app.funcapp.app_settings["Acmebot:Endpoint"] == "https://acme-v02.api.letsencrypt.org/directory" &&
      !contains(keys(azurerm_windows_function_app.funcapp.app_settings), "FUNCTIONS_INPROC_NET8_ENABLED") &&
      output.package_url == "https://github.com/polymind-inc/acmebot/releases/download/v5.1.5/acmebot.zip" &&
      azurerm_windows_function_app.funcapp.app_settings["WEBSITE_RUN_FROM_PACKAGE"] == output.package_url
    )
    error_message = "v5 must select its package and .NET 10 isolated configuration without the in-process flag."
  }
}

run "v4_rollback_runtime" {
  command = plan

  variables {
    acme_version = "v4.3.1"
  }

  assert {
    condition = (
      !local.acme_is_v5 &&
      azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].dotnet_version == "v8.0" &&
      !azurerm_windows_function_app.funcapp.site_config[0].application_stack[0].use_dotnet_isolated_runtime &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_WORKER_RUNTIME"] == "dotnet" &&
      azurerm_windows_function_app.funcapp.app_settings["FUNCTIONS_INPROC_NET8_ENABLED"] == "1" &&
      azurerm_windows_function_app.funcapp.app_settings["Acmebot:Endpoint"] == "https://acme-v02.api.letsencrypt.org/" &&
      !contains(keys(azurerm_windows_function_app.funcapp.app_settings), "FUNCTIONS_EXTENSION_VERSION") &&
      output.package_url == "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/4.3.1.zip"
    )
    error_message = "Selecting v4 again must restore the package and in-process configuration."
  }
}
