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

The stage names in Azure DevOps can only contain letters, numbers and underscores. 

The service connection names can only contain letters, numbers and hyphens.

The pipeline parameters for environment and product will be computed based on the name of the subscription.

When adding a new subscription you need to make the Service Principal of the new subscription `DTS Bootstrap (sub:SUBSCRIPTION_NAME)` the owner of the `DTS Public DNS Contributor (env:ENVIRONMENT)` group.

Elevate your permissions by going to the [PIM settings](https://portal.azure.com/#blade/Microsoft_Azure_PIMCommon/CommonMenuBlade/quickStart).

Click on My roles under tasks in the left hand side. Select Activate next to User Administrator. Then submit your request for elevated permissions. Once that is complete you will be able to run the command below successfully. 

Edit and run the command below, replacing ENVIRONMENT_NAME with the environment name and SUBSCRIPTION_NAME with the subscription name.

```shell
az ad group owner add --group "DTS Public DNS Contributor (env:ENVIRONMENT_NAME)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:SUBSCRIPTION_NAME)" --query '[].{id:id}' -o tsv)
```

For example if you wanted to make `DTS Bootstrap (sub:dcd-cftapps-sbox)` a group owner of the `DTS Public DNS Contributor (env:sbox)` group you would run the following command:

```shell
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-sbox)" --query '[].{id:id}' -o tsv)
```

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

## Testing Acmebot v5 in SDS sandbox

The `dts_sharedservices_sbox` pipeline stage uses
`environments/sbox/dts_sharedservices_sbox.tfvars` to override `acme_version`
to `v5.1.5`. Other stages still use their existing environment tfvars and
the default `v4.3.1`. Do not change the global default or the shared
`environments/sbox/sbox.tfvars` for this single-subscription test.

Selecting v5 also selects .NET 10 isolated, sets
`FUNCTIONS_WORKER_RUNTIME=dotnet-isolated` and `FUNCTIONS_EXTENSION_VERSION=~4`,
and removes `FUNCTIONS_INPROC_NET8_ENABLED`. v4 retains its existing .NET 8
in-process settings. AzureRM is pinned to `4.54.0`, the first release with
Windows Function App .NET 10 support; review plans for provider-related drift.

Run the configuration checks from `components/acme` using Terraform `1.17.1`:

```shell
terraform init -backend=false
terraform validate
terraform test -filter=tests/runtime.tftest.hcl
```

The tests use mocked providers and verify the v4 default, v5 runtime settings
and the v4 rollback configuration without connecting to Azure.

Before applying:

1. Make the official `v5.1.5` release asset `acmebot.zip` available at
   `https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v5/5.1.5.zip`.
   Verify it is downloadable from the Function App's network. Terraform does
   not upload the package.
2. Back up the SDS sandbox Function App configuration and record existing
   certificate names, versions and expiry dates. Keep the v4 package available.
3. Manually queue the pipeline from the test branch with `overrideAction=plan`
   and select only `Precheck` and `dts_sharedservices_sbox_acme` in **Stages to run**.
   Review the runtime and package changes and ensure there are no unexpected
   replacements or deletions.
4. After review, queue the same branch with `overrideAction=apply` and the same
   stage selection. A CI-triggered main build can apply all stages automatically;
   do not merge the test before approving that wider execution.

Open the default domain for `acmedtssdssbox`, confirm the v5 dashboard and
Function App startup are healthy, then issue a certificate for an approved
sandbox test hostname using the
[certificate runbook](https://hmcts.github.io/ops-runbooks/Certificates/letsencrypt.html).
Confirm the certificate appears in the SDS sandbox Key Vault, has the expected
SANs and expiry, and that renewal succeeds. Check Application Insights for
worker, DNS challenge and renewal errors. Creating a certificate alone does not
verify automatic renewal; observe a scheduled renewal when due as well.
The runbook predates v5, so use the dashboard if its legacy URL paths differ.

To roll back, set `acme_version = "v4.3.1"` in the SDS-specific tfvars file,
review the plan and apply only the SDS sandbox stage. This restores the v4
package and in-process settings; confirm startup and certificate management
again.
