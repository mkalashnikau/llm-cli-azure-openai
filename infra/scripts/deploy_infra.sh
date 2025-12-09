#!/bin/bash
set -e

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-default}"
LOCATION="${LOCATION:-GermanyWestCentral}"
ACCOUNT_NAME="${ACCOUNT_NAME:-llm-oai}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-gpt-4o-mini-deployment}"
MODEL_NAME="${MODEL_NAME:-gpt-4o-mini}"
MODEL_VERSION="${MODEL_VERSION:-2024-07-18}"
SKU="${SKU:-S0}"
SKU_CAPACITY="${SKU_CAPACITY:-1}"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Azure OpenAI infrastructure

OPTIONS:
    -g, --resource-group    Resource group name (default: ${RESOURCE_GROUP})
    -l, --location          Azure region (default: ${LOCATION})
    -n, --account-name      OpenAI account name (default: ${ACCOUNT_NAME})
    -d, --deployment-name   Deployment name (default: ${DEPLOYMENT_NAME})
    -m, --model-name        Model name (default: ${MODEL_NAME})
    -v, --model-version     Model version (default: ${MODEL_VERSION})
    -s, --sku               SKU tier (default: ${SKU})
    -c, --capacity          SKU capacity (default: ${SKU_CAPACITY})
    -h, --help              Display this help message

EXAMPLES:
    $0
    $0 -n my-openai -g my-resource-group
    $0 --model-name gpt-4 --model-version 2024-11-01
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -n|--account-name)
            ACCOUNT_NAME="$2"
            shift 2
            ;;
        -d|--deployment-name)
            DEPLOYMENT_NAME="$2"
            shift 2
            ;;
        -m|--model-name)
            MODEL_NAME="$2"
            shift 2
            ;;
        -v|--model-version)
            MODEL_VERSION="$2"
            shift 2
            ;;
        -s|--sku)
            SKU="$2"
            shift 2
            ;;
        -c|--capacity)
            SKU_CAPACITY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

echo "==================================="
echo "Azure OpenAI Deployment Configuration"
echo "==================================="
echo "Resource Group:    ${RESOURCE_GROUP}"
echo "Location:          ${LOCATION}"
echo "Account Name:      ${ACCOUNT_NAME}"
echo "Deployment Name:   ${DEPLOYMENT_NAME}"
echo "Model Name:        ${MODEL_NAME}"
echo "Model Version:     ${MODEL_VERSION}"
echo "SKU:               ${SKU}"
echo "Capacity:          ${SKU_CAPACITY}"
echo "==================================="
echo

# Create Azure OpenAI account
echo "Creating Azure OpenAI account..."
az cognitiveservices account create \
  --name "${ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --kind OpenAI \
  --sku "${SKU}" \
  --yes

echo "✓ Azure OpenAI account created successfully"
echo

# Create model deployment
echo "Creating model deployment..."
az cognitiveservices account deployment create \
  --name "${ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --deployment-name "${DEPLOYMENT_NAME}" \
  --model-name "${MODEL_NAME}" \
  --model-version "${MODEL_VERSION}" \
  --model-format OpenAI \
  --sku-capacity "${SKU_CAPACITY}" \
  --sku-name Standard

echo "✓ Model deployment created successfully"
echo

# Retrieve and display API key
echo "Retrieving API key..."
API_KEY=$(az cognitiveservices account keys list \
  --name "${ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "key1" -o tsv)

echo "✓ API key retrieved"
echo

# Retrieve and display endpoint
echo "Retrieving endpoint..."
ENDPOINT=$(az cognitiveservices account show \
  --name "${ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "properties.endpoint" -o tsv)

echo "✓ Endpoint retrieved"
echo

# Display final configuration
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo "Set these environment variables:"
echo
echo "export AZURE_OPENAI_ENDPOINT=\"${ENDPOINT}\""
echo "export AZURE_OPENAI_KEY=\"${API_KEY}\""
echo "export AZURE_OPENAI_DEPLOYMENT=\"${DEPLOYMENT_NAME}\""
echo "export AZURE_OPENAI_API_VERSION=\"2024-02-15-preview\""
echo "==================================="