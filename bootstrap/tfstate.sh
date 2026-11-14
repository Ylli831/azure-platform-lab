#!/usr/bin/env bash
# Bootstrap: create the storage account that holds Terraform's remote state.
# Terraform can't create the place its own state lives, so this one step is plain az CLI.
# Safe to re-run: it reuses the storage account if it already exists.
set -euo pipefail

LOCATION="westeurope"
RG="rg-azlab-tfstate"
CONTAINER="tfstate"

az group create --name "$RG" --location "$LOCATION" --tags project=azlab purpose=tfstate -o none

SA=$(az storage account list --resource-group "$RG" --query "[0].name" -o tsv)
if [ -z "$SA" ]; then
  SA="stazlabtf$(openssl rand -hex 4)"
  az storage account create \
    --name "$SA" \
    --resource-group "$RG" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --allow-shared-key-access false \
    --tags project=azlab purpose=tfstate \
    -o none
fi

az storage account blob-service-properties update \
  --account-name "$SA" --resource-group "$RG" --enable-versioning true -o none

SA_ID=$(az storage account show --name "$SA" --resource-group "$RG" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
HAS_ROLE=$(az role assignment list --assignee "$ME" --role "Storage Blob Data Contributor" --scope "$SA_ID" --query "length(@)" -o tsv)
if [ "$HAS_ROLE" = "0" ]; then
  az role assignment create \
    --assignee-object-id "$ME" --assignee-principal-type User \
    --role "Storage Blob Data Contributor" --scope "$SA_ID" -o none
fi

for attempt in 1 2 3 4 5 6 7 8 9; do
  if az storage container create --name "$CONTAINER" --account-name "$SA" --auth-mode login -o none 2>/dev/null; then
    break
  fi
  echo "Waiting for the role assignment to take effect (attempt $attempt)..."
  sleep 20
done
az storage container show --name "$CONTAINER" --account-name "$SA" --auth-mode login -o none

cat <<EOF
Remote state is ready:
  resource_group_name  = "$RG"
  storage_account_name = "$SA"
  container_name       = "$CONTAINER"
EOF
