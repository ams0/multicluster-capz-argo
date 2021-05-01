#!/bin/bash

#Install clusterctl on mac
#brew install clusterctl

#Uncomment below if you don't have these already set as environment variables
#export AZURE_SUBSCRIPTION_ID=
#export AZURE_TENANT_ID=
#export AZURE_CLIENT_ID=
#export AZURE_CLIENT_SECRET=

export AZURE_ENVIRONMENT="AzurePublicCloud"

export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "$AZURE_SUBSCRIPTION_ID" | base64 | tr -d '\n')"
export AZURE_TENANT_ID_B64="$(echo -n "$AZURE_TENANT_ID" | base64 | tr -d '\n')"
export AZURE_CLIENT_ID_B64="$(echo -n "$AZURE_CLIENT_ID" | base64 | tr -d '\n')"
export AZURE_CLIENT_SECRET_B64="$(echo -n "$AZURE_CLIENT_SECRET" | base64 | tr -d '\n')"

export EXP_MACHINE_POOL=true
export EXP_AKS=true

clusterctl init --infrastructure azure
