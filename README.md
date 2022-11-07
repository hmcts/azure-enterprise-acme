# Azure Enterprise ACME

This repo will deploy ACME (Automated Certificate Management Environment) resources for subscriptions that require them.

## Pre-requisites

In order to create ACME resources in a subscription, the pipeline in this repo must run with a service connection scoped to that subscription. 

The service connections are created in the [hmcts/azure-enterprise](https://github.com/hmcts/azure-enterprise) repo.

The subscription must be added to the prod.tfvars file in that repo and the pipeline ran so that the subscription and service connection are created.

A Global Administrator must grant consent for the tenant to the service principal being used by the service connection.

This is required for the service connection to be able to create the application registration for ACME.

## Adding a new subscription

To add a new subscription, simply add a stage to the environment_components parameter e.g.

```yaml
      - stage: 'dcd_cft_sandbox'
        service_connection: 'dcd-cft-sandbox'
```

The stage names in Azure DevOps can only contain letters, numbers and hyphens. 

The service connection names can only contain letters, numbers and underscores.

The pipeline parameters for environment and product will be computed based on the name of the subscription.

When adding a new subscription you need to make the Service Principal of the new subscription the owner of the DTS Public DNS Contributor (env:ENVIRONMENT) group.

Update the script in scripts/dnsgroupowner.sh with the correct ENVIRONMENT and SUBSCRIPTION,  Uncomment the Add_ownership_to_DNS_groups Stage and change the dependsOn in Stage ${{ deployment.stage }}_acme to 'Add_ownership_to_DNS_groups' on the azure-pipeline.yml.

Once the pipeline has ran and added the ownership to the group you need to comment out Add_ownership_to_DNS_groups Stage and change the dependsOn in Stage ${{ deployment.stage }}_acme to Precheck.

## Importing an existing subscription

1. Ensure you have azure-cli installed and logged in as well as terraform and jq.

2. Create a file called subscriptions.json in the scripts folder and create a json array with the subscription to be imported and its details e.g.

```json
   [
      {
         "subscription_name": "DCD-CFT-Sandbox"
      },
      {
         "subscription_name": "DCD-CFTAPPS-SBOX"
      },
   ]
```

3. Run terraform init inside the components/enterprise directory for the environment you are targeting.

4. Run the script from the components/enterprise directory without any flags to perform a dry-run i.e. `scripts/terraform-import.sh`. The script will output the resources to be imported and their address IDs. Check these values are expected.

5. If the values returned by the dry-run are correct, run the script again and append `--import`. This will run `terraform import`.

   Terraform will attempt to import the resources to the address IDs.
