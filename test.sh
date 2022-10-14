az account subscription list --query "[?displayName=='$SUBSCRIPTION_NAME'].{subscriptionId:subscriptionId}"
