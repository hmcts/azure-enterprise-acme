#!/bin/bash
set -xe
SUBSCRIPTION_NAME=DCD-CFT-Sandbox
az account subscription list --query "[?displayName=='$SUBSCRIPTION_NAME'].{subscriptionId:subscriptionId}"
