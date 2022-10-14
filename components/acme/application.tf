locals {
  app_name = "acme-${lower(data.azurerm_subscription.subscriptionid.display_name)}"
}


resource "random_uuid" "app_uuid" {}

resource "azuread_application" "appreg" {
  provider     = azurerm.control
  display_name = local.app_name
  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${local.app_name} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${local.app_name}"
      id                         = random_uuid.app_uuid.result
      enabled                    = true
      type                       = "User"
      user_consent_description   = "Allow the application to access ${local.app_name} on your behalf."
      user_consent_display_name  = "Access ${local.app_name}"
      value                      = "user_impersonation"
    }
  }
  web {
    redirect_uris = ["https://acme${replace(local.name, "-", "")}.azurewebsites.net/.auth/login/aad/callback"]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}