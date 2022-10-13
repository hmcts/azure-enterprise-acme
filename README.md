# Azure Enterprise ACME

This repo will deploy ACME (Automated Certificate Management Environment) resources for subscriptions that require them.

## Pre-requisites

In order to create ACME resources in a subscription, the pipeline in this repo must run with a service connection scoped to that subscription. 

The service connections are created in the [hmcts/azure-enterprise](https://github.com/hmcts/azure-enterprise) repo.

The subscription must be added to the prod.tfvars file in that repo and the pipeline ran so that the subscription and service connection are created.

## Adding a new subscription

To add a new subscription, simply add a stage to the environment_components parameter e.g.

```yaml
      - stage: 'dcd_cft_sandbox'
        service_connection: 'dcd-cft-sandbox'
```

The stage names in Azure DevOps can only contain letters, numbers and hyphens. 

The service connection names can only contain letters, numbers and underscores.

The pipeline parameters for environment and product will be computed based on the name of the subscription.