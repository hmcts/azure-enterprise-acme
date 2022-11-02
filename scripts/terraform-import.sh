oldIFS=$IFS
IFS=$'\n'
SDS=sds

# by default the script will assume you want a dry-run to see what resources will be imported
# pass the `--import` argument to initiate terraform import

if [ "$1" != "--import" ]; then
echo "This is a dry-run\nAppend --import to run terraform import"
fi

if [ "$1" = "--import" ]; then
    echo "You have specified the --import flag. This will perform terraform import\nRemove this flag to perform a dry-run"
    read -n1 -p "Do you wish to run terraform import? [y,n]" input 

    if [[ $input == "Y" || $input == "y" ]]; then
        echo "\nImporting resources into terraform state"
    else
        echo "\nYou have selected no. Exiting..."
        exit 1
    fi
fi

# check required az extensions are installed
extensions='[
        {
            "name": "account"
        }
    ]'

for extension in $(echo "${extensions[@]}" | jq -r '.[].name'); do
    AZ_EXTENSION=$(az extension list --query "[?name=='${extension}']")
    if [ "$AZ_EXTENSION" = "[]" ]; then
        echo "\nInstalling azure cli extensions..."
        az extension add --name $extension
    fi
done

subscriptions=$(cat ../../scripts/subscriptions.json)

for subscription in $(echo "${subscriptions[@]}" | jq -c '.[]'); do

    # get subscription name
    SUBSCRIPTION_NAME=$(echo $subscription | jq -r '.subscription_name')
    echo "SUBSCRIPTION_NAME is $SUBSCRIPTION_NAME"

    # get subscription id
    SUBSCRIPTION_ID=$(az account subscription list --query "[?displayName=='${SUBSCRIPTION_NAME}'].{subscriptionId:subscriptionId}" --only-show-errors -o tsv)
    echo "SUBSCRIPTION_ID is $SUBSCRIPTION_ID"

    # get backend subscription id
    BACKEND_SUBSCRIPTION_ID=$(echo $subscription | jq -r '.backend_subscription_id')
    echo "BACKEND_SUBSCRIPTION_ID is $BACKEND_SUBSCRIPTION_ID"

    # get backend tenant id
    TENANT_ID=$(echo $subscription | jq -r '.tenant_id')
    echo "TENANT_ID is $TENANT_ID"

    # get environment
    ENVIRONMENT=$(echo "${subscription}" | jq -r '.environment')
    echo "ENVIRONMENT is $ENVIRONMENT"

    PRODUCT=$(echo "${subscription}" | jq -r '.product')
    echo "PRODUCT is $PRODUCT"

    SP_OBJECT_ID=$(az ad sp list --display-name "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') --query '[].{id:id}' -o tsv)
    echo "SP_OBJECT_ID is $SP_OBJECT_ID"

    DTS_GROUP_OBJECT_ID=$(az ad group list --display-name "DTS Platform Operations" --filter "displayname eq 'DTS Platform Operations' and securityEnabled eq "true"" --query '[].{id:id}' -o tsv)
    echo "DTS_GROUP_OBJECT_ID is $DTS_GROUP_OBJECT_ID"

    DTS_Public_DNS_Contributor_ID=$(az ad group show -g "DTS Public DNS Contributor (env:${ENVIRONMENT})" --query '{id:id}' -o tsv)
    echo "DTS_Public_DNS_Contributor_ID is $DTS_Public_DNS_Contributor_ID"
    # set context
    echo "Setting Azure CLI context to subscription $SUBSCRIPTION_NAME"
    az account set -s ${SUBSCRIPTION_NAME}

    RESOURCE_GROUP_ID=$(az group show --name ${PRODUCT}-${ENVIRONMENT}-rg --query '{id:id}' -o tsv)
    KEYVAULT_ID=$(az keyvault show --name "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') --query '{id:id}' -o tsv)
    STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='acme$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')'].{id:id}" -o tsv)
    FUNCTION_APP_READER=$(az role assignment list --assignee ${SP_OBJECT_ID} --scope ${RESOURCE_GROUP_ID} --query "[?roleDefinitionName=='Reader'].{id:id}" -o tsv)
    FUNCTION_APP_KV_ACCESS=$(az role assignment list --assignee ${SP_OBJECT_ID} --scope ${KEYVAULT_ID} --query "[?roleDefinitionName=='Key Vault Administrator'].{id:id}" -o tsv)
    KV_GROUP_ACCESS=$(az role assignment list --assignee ${DTS_GROUP_OBJECT_ID} --scope ${KEYVAULT_ID} --query "[?roleDefinitionName=='Key Vault Administrator'].{id:id}" -o tsv)
    APP_SERVICE_PLAN=$(az appservice plan show -n ${PRODUCT}-${ENVIRONMENT}-asp -g ${PRODUCT}-${ENVIRONMENT}-rg --query '{id:id}' -o tsv)
    FUNCTION_APP_ID=$(az functionapp show -n "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') -g ${PRODUCT}-${ENVIRONMENT}-rg --query '{id:id}' -o tsv)
    FUNCTION_APP_OBJECT_ID=$(az functionapp show -n "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') -g ${PRODUCT}-${ENVIRONMENT}-rg --query "identity.principalId" -o tsv)
    APPLICATION_INSIGHT_ID=$(az monitor app-insights component show -a ${PRODUCT}-${ENVIRONMENT} -g ${PRODUCT}-${ENVIRONMENT}-rg --query '{id:id}' -o tsv)

        if [ "$1" = "--import" ]; then
            rm -rf .terraform .terraform.lock.hcl

            echo "Running Terraform Init"
            terraform init -backend-config=storage_account_name="$(echo c${SUBSCRIPTION_ID:0:8}${SUBSCRIPTION_ID:24:32}sa)" -backend-config=container_name=subscription-tfstate -backend-config=key="UK South/${PRODUCT}/azure-enterprise-acme/${ENVIRONMENT}/acme/terraform.tfstate" -backend-config=resource_group_name=azure-control-${ENVIRONMENT}-rg -backend-config=subscription_id=${SUBSCRIPTION_ID} -backend-config=tenant_id=${TENANT_ID} -backend-config=subscription_id=${BACKEND_SUBSCRIPTION_ID}

            # terraform state rm  module.acme.azurerm_key_vault.kv
            # terraform state rm  module.acme.azurerm_storage_account.stg 
            # terraform state rm  module.acme.azurerm_role_assignment.Reader
            # terraform state rm  module.acme.azurerm_role_assignment.kvaccess
            # terraform state rm  module.acme.azurerm_role_assignment.kvgroupaccess
            # terraform state rm  module.acme.azurerm_resource_group.rg 
            # terraform state rm  module.acme.azurerm_service_plan.asp
            # terraform state rm  module.acme.azurerm_windows_function_app.funcapp
            # terraform state rm  module.acme.azuread_group_member.dnszonecontributor
            # terraform state rm  module.acme.azurerm_application_insights.appinsight

           echo "Importing ACME resources into terraform state..."
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_key_vault.kv $KEYVAULT_ID
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_storage_account.stg $STORAGE_ACCOUNT_ID
             terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_role_assignment.Reader ${FUNCTION_APP_READER}
             terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_role_assignment.kvaccess ${FUNCTION_APP_KV_ACCESS}
             terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_role_assignment.kvgroupaccess ${KV_GROUP_ACCESS}
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_resource_group.rg ${RESOURCE_GROUP_ID}
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_service_plan.asp ${APP_SERVICE_PLAN}
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_windows_function_app.funcapp ${FUNCTION_APP_ID}
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azuread_group_member.dnszonecontributor ${DTS_Public_DNS_Contributor_ID}/member/${FUNCTION_APP_OBJECT_ID}
            # terraform import -var builtFrom=azure-enterprise -var env=${ENVIRONMENT} -var product=enterprise -var-file=../../environments/${ENVIRONMENT}/${ENVIRONMENT}.tfvars azurerm_application_insights.appinsight ${APPLICATION_INSIGHT_ID}

        else
            echo "ACME keyvault $(echo "acme"$(echo "${SUBSCRIPTION_NAME/SHAREDSERVICES/$SDS}" | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to azurerm_key_vault.kv"
            echo "ACME storage account $(echo "acme"$(echo "${SUBSCRIPTION_NAME/SHAREDSERVICES/$SDS}" | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to azurerm_storage_account.stg"
            echo "Role assignment $FUNCTION_APP_READER"
            echo "Role assignment $FUNCTION_APP_KV_ACCESS"
            echo "Role assignment $KV_GROUP_ACCESS"
            echo "App service plan" $APP_SERVICE_PLAN
            echo "Function app" $FUNCTION_APP_ID
            echo "Application insight" $APPLICATION_INSIGHT_ID
        fi
done
IFS=$oldIFS