#!/usr/bin/env pwsh
#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Resource group name")]
    [string]$ResourceGroup = $env:RESOURCE_GROUP ?? "rg-default",
    
    [Parameter(HelpMessage = "Azure region")]
    [string]$Location = $env:LOCATION ?? "GermanyWestCentral",
    
    [Parameter(HelpMessage = "OpenAI account name")]
    [string]$AccountName = $env:ACCOUNT_NAME ?? "llm-oai",
    
    [Parameter(HelpMessage = "Deployment name")]
    [string]$DeploymentName = $env:DEPLOYMENT_NAME ?? "gpt-4o-mini-deployment",
    
    [Parameter(HelpMessage = "Model name")]
    [string]$ModelName = $env:MODEL_NAME ?? "gpt-4o-mini",
    
    [Parameter(HelpMessage = "Model version")]
    [string]$ModelVersion = $env:MODEL_VERSION ?? "2024-07-18",
    
    [Parameter(HelpMessage = "SKU tier")]
    [string]$Sku = $env:SKU ?? "S0",
    
    [Parameter(HelpMessage = "SKU capacity")]
    [int]$SkuCapacity = $env:SKU_CAPACITY ?? 1,
    
    [Parameter(HelpMessage = "Display help message")]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host @"

Usage: ./deploy_azure_infra.ps1 [OPTIONS]

Deploy Azure OpenAI infrastructure

OPTIONS:
    -ResourceGroup      Resource group name (default: $ResourceGroup)
    -Location           Azure region (default: $Location)
    -AccountName        OpenAI account name (default: $AccountName)
    -DeploymentName     Deployment name (default: $DeploymentName)
    -ModelName          Model name (default: $ModelName)
    -ModelVersion       Model version (default: $ModelVersion)
    -Sku                SKU tier (default: $Sku)
    -SkuCapacity        SKU capacity (default: $SkuCapacity)
    -Help               Display this help message

EXAMPLES:
    ./deploy_azure_infra.ps1
    ./deploy_azure_infra.ps1 -AccountName "my-openai" -ResourceGroup "my-resource-group"
    ./deploy_azure_infra.ps1 -ModelName "gpt-4" -ModelVersion "2024-11-01"

"@
    exit 0
}

if ($Help) {
    Show-Usage
}

# Display configuration
Write-Host "==================================="
Write-Host "Azure OpenAI Deployment Configuration"
Write-Host "==================================="
Write-Host "Resource Group:    $ResourceGroup"
Write-Host "Location:          $Location"
Write-Host "Account Name:      $AccountName"
Write-Host "Deployment Name:   $DeploymentName"
Write-Host "Model Name:        $ModelName"
Write-Host "Model Version:     $ModelVersion"
Write-Host "SKU:               $Sku"
Write-Host "Capacity:          $SkuCapacity"
Write-Host "==================================="
Write-Host ""

try {
    # Create Azure OpenAI account
    Write-Host "Creating Azure OpenAI account..."
    az cognitiveservices account create `
        --name $AccountName `
        --resource-group $ResourceGroup `
        --location $Location `
        --kind OpenAI `
        --sku $Sku `
        --yes

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create Azure OpenAI account"
    }

    Write-Host "✓ Azure OpenAI account created successfully" -ForegroundColor Green
    Write-Host ""

    # Create model deployment
    Write-Host "Creating model deployment..."
    az cognitiveservices account deployment create `
        --name $AccountName `
        --resource-group $ResourceGroup `
        --deployment-name $DeploymentName `
        --model-name $ModelName `
        --model-version $ModelVersion `
        --model-format OpenAI `
        --sku-capacity $SkuCapacity `
        --sku-name Standard

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create model deployment"
    }

    Write-Host "✓ Model deployment created successfully" -ForegroundColor Green
    Write-Host ""

    # Retrieve and display API key
    Write-Host "Retrieving API key..."
    $apiKey = az cognitiveservices account keys list `
        --name $AccountName `
        --resource-group $ResourceGroup `
        --query "key1" -o tsv

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to retrieve API key"
    }

    Write-Host "✓ API key retrieved" -ForegroundColor Green
    Write-Host ""

    # Retrieve and display endpoint
    Write-Host "Retrieving endpoint..."
    $endpoint = az cognitiveservices account show `
        --name $AccountName `
        --resource-group $ResourceGroup `
        --query "properties.endpoint" -o tsv

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to retrieve endpoint"
    }

    Write-Host "✓ Endpoint retrieved" -ForegroundColor Green
    Write-Host ""

    # Display final configuration
    Write-Host "==================================="
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "==================================="
    Write-Host "Set these environment variables:"
    Write-Host ""
    Write-Host "# PowerShell"
    Write-Host "`$env:AZURE_OPENAI_ENDPOINT = `"$endpoint`""
    Write-Host "`$env:AZURE_OPENAI_KEY = `"$apiKey`""
    Write-Host "`$env:AZURE_OPENAI_DEPLOYMENT = `"$DeploymentName`""
    Write-Host "`$env:AZURE_OPENAI_API_VERSION = `"2024-02-15-preview`""
    Write-Host ""
    Write-Host "# Bash/Zsh"
    Write-Host "export AZURE_OPENAI_ENDPOINT=`"$endpoint`""
    Write-Host "export AZURE_OPENAI_KEY=`"$apiKey`""
    Write-Host "export AZURE_OPENAI_DEPLOYMENT=`"$DeploymentName`""
    Write-Host "export AZURE_OPENAI_API_VERSION=`"2024-02-15-preview`""
    Write-Host "==================================="

} catch {
    Write-Error "Deployment failed: $_"
    exit 1
}
