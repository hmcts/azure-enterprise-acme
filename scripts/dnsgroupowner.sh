az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-cftsbox-intsvc)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservicesptl-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-hub-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:cts-hub-sbox-intsvchm)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:sbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-soc-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:demo)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftappsdata-demo)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:demo)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-demo)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:demo)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-demo)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:ptlsbox)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservicesptl-sbox)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:test)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-test)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:test)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-test)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:test)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-hub-test)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:test)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cnp-qa)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:ptl)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-cftptl-intsvc)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:ptl)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservicesptl)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-prod)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cnp-prod)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-prod)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-hub-prod-intsvc)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-soc-prod)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:prod)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cft-vh-pilot)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:stg)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-stg)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:stg)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-stg)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:ithc)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-ithc)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:ithc)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-ithc)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cftapps-dev)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cft-idam-dev)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dcd-cnp-dev)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:dts-sharedservices-dev)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:hmcts-hub-dev)" --query '[].{id:id}' -o tsv)
az ad group owner add --group "DTS Public DNS Contributor (env:dev)" --owner-object-id $(az ad sp list --display-name "DTS Bootstrap (sub:reform-cft-vh-dev)" --query '[].{id:id}' -o tsv)