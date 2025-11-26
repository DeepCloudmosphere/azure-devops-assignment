# set -euo pipefail

# RG=${1:-tfstate-rg}
# LOCATION=${2:-eastus}
# SA_NAME=${3:-tfstate$(date +%s | sha256sum | head -c 8)} # must be globally unique
# CONTAINER=${4:-tfstate}
# SUBSCRIPTION_ID=${5:-ed205901-4c9d-4434-9941-02372033ca67} # optional; if blank use current az cli context

# echo "Bootstrap: resource-group=$RG, location=$LOCATION, storage-account=$SA_NAME, container=$CONTAINER"

# if [ "$SUBSCRIPTION_ID" != "ed205901-4c9d-4434-9941-02372033ca67" ] && [ -n "$SUBSCRIPTION_ID" ]; then
#   az account set --subscription "$SUBSCRIPTION_ID"
# fi

# echo "Creating resource group..."
# az group create -n "$RG" -l "$LOCATION" --output none

# echo "Creating storage account (Standard_LRS)..."
# az storage account create -n "$SA_NAME" -g "$RG" -l "$LOCATION" --sku Standard_LRS --kind StorageV2 --https-only true --output none

# echo "Retrieving storage account key..."
# ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA_NAME" --query "[0].value" -o tsv)

# echo "Creating container..."
# az storage container create --name "$CONTAINER" --account-name "$SA_NAME" --account-key "$ACCOUNT_KEY" --output none

# cat > ../backend.tfvars <<EOF
# resource_group_name = "$RG"
# storage_account_name = "$SA_NAME"
# container_name = "$CONTAINER"
# key = "prod/terraform.tfstate"
# EOF

# echo "Created ../backend.tfvars. Now run:"
# echo "  cd .."
# echo "  terraform init -backend-config=backend.tfvars"
# echo ""
# echo "Bootstrap finished."


#!/usr/bin/env bash
# terraform/bootstrap/bootstrap.sh
# Usage (simple): ./bootstrap.sh
# Optional args:
#   ./bootstrap.sh <tfstate-rg> <location> <storage-account-name> <container-name>
set -euo pipefail

RG=${1:-tfstate-rg}
LOCATION=${2:-eastus}
SA_NAME=${3:-""}
CONTAINER=${4:-tfstate}

# Detect current subscription
CURRENT_SUB=$(az account show --query id -o tsv 2>/dev/null || true)
if [ -z "$CURRENT_SUB" ]; then
  echo "ERROR: No active Azure subscription. Run 'az login' and select the desired subscription with 'az account set --subscription <id>'."
  exit 1
fi

echo "Using Azure subscription: $CURRENT_SUB"
echo "Resource group: $RG"
echo "Location: $LOCATION"
echo "Container: $CONTAINER"

# If storage account name not provided, create a reasonably unique one
if [ -z "$SA_NAME" ]; then
  # must be 3-24 lowercase letters and numbers
  RAND=$(date +%s | sha256sum | cut -c1-6)
  SA_NAME="${RG}sa${RAND}"
  # normalize: strip non-alphanumeric and lowercase
  SA_NAME=$(echo "$SA_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-20)
  echo "No storage account name given. Generated: $SA_NAME"
fi

# Validate storage account name rules
if [[ ! $SA_NAME =~ ^[a-z0-9]{3,24}$ ]]; then
  echo "ERROR: Storage account name must be 3-24 lowercase letters and numbers. Provided: $SA_NAME"
  exit 1
fi

# Create resource group if missing
echo "Ensuring resource group exists..."
az group create -n "$RG" -l "$LOCATION" --output none

# Ensure Microsoft.Storage provider is registered (helpful in some subscriptions)
PROV_STATE=$(az provider show -n Microsoft.Storage --query "registrationState" -o tsv 2>/dev/null || echo "NotFound")
if [ "$PROV_STATE" != "Registered" ]; then
  echo "Registering provider Microsoft.Storage (current state: $PROV_STATE)..."
  az provider register --namespace Microsoft.Storage --wait
fi

# Create storage account
echo "Creating storage account '$SA_NAME' in resource group '$RG'..."
az storage account create \
  -n "$SA_NAME" \
  -g "$RG" \
  -l "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --output none

echo "Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA_NAME" --query "[0].value" -o tsv)

echo "Creating blob container '$CONTAINER'..."
az storage container create --name "$CONTAINER" --account-name "$SA_NAME" --account-key "$ACCOUNT_KEY" --output none

# Write backend.tfvars in parent folder
BACKEND_FILE="../backend.tfvars"
cat > "$BACKEND_FILE" <<EOF
resource_group_name = "$RG"
storage_account_name = "$SA_NAME"
container_name = "$CONTAINER"
key = "prod/terraform.tfstate"
EOF

echo "Wrote backend config to $BACKEND_FILE"
echo ""
echo "Bootstrap finished. Next steps:"
echo "  cd .."
echo "  terraform init -backend-config=backend.tfvars"
echo ""
