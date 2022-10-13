oldIFS=$IFS
IFS=$'\n'

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

    # get environment
    ENVIRONMENT=$(echo "${subscription}" | jq -r '.environment')
    echo "ENVIRONMENT is $ENVIRONMENT"

    # set context
    echo "Setting Azure CLI context to subscription $SUBSCRIPTION_NAME"
    az account set -s ${SUBSCRIPTION_NAME}

    APP_ID=$(az ad app list --display-name "acme-"${SUBSCRIPTION_NAME} --query '[].{id:id}' -o tsv)
    KEYVAULT_ID=$(az keyvault show --name "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g') --query '{id:id}' -o tsv)
    STORAGE_ACCOUNT_ID=$(az storage account list --query "[?name=='acme$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')'].{id:id}" -o tsv)
    # WEBAPP_ID=$(az webapp show --name $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) --resource-group cft-platform-${ENVIRONMENT}-rg --query '{id:id}' -o tsv)

        if [ "$1" = "--import" ]; then

            echo "Importing ACME resources into terraform state..."
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme.azuread_application.appreg $APP_ID
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme.azurerm_key_vault.kv $KEYVAULT_ID
            terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme.azurerm_storage_account.stg $STORAGE_ACCOUNT_ID
            # terraform import -var builtFrom=azure-enterprise -var env=prod -var product=enterprise -var-file=../../environments/prod/prod.tfvars module.acme.windows_function_app.func_app $WEBAPP_ID
        else
            echo "ACME application registration $APP_ID will be imported to module.acme.azuread_application.appreg"
            echo "ACME keyvault $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to module.acme.azurerm_key_vault.kv"
            echo "ACME storage account $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to module.acme.azurerm_storage_account.stg"
            echo "ACME function app $(echo "acme"$(echo ${SUBSCRIPTION_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/-//g')) will be imported to module.acme.windows_function_app.func_app"
        fi
done
IFS=$oldIFS