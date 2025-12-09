# LLM CLI - Azure OpenAI Chat Tool

A command-line interface for interacting with Azure OpenAI models in an interactive chat session with streaming responses.

## Features

- 🤖 Interactive chat with Azure OpenAI models
- 📝 Configurable system prompts for customizing LLM behavior
- 🌊 Streaming responses for real-time output
- 💬 Conversation history maintained throughout the session
- ⚡ Built with Go and Cobra CLI framework

## Prerequisites

- Go 1.24.4 or higher
- Existing Azure OpenAI resource with a deployed model
- (Optional) Azure CLI installed and configured
- (Optional) Azure subscription with permissions to create Cognitive Services resources

## Installation

Clone the repository:

```bash
git clone https://github.com/mkalashnikau/llm-cli-azure-openai.git
cd llm-cli-azure-openai
```

Install dependencies:

```bash
go mod download
```

Build the application:

```bash
go build -o llm_cli
```

## Azure Infrastructure Deployment

If you don't have an Azure OpenAI resource yet, you can deploy one using the provided script.

### Prerequisites for Deployment

1. **Install Azure CLI**: [Installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. **Login to Azure**:
```bash
az login
```

3. **Set your subscription** (if you have multiple):
```bash
az account set --subscription "your-subscription-id"
```

### Deploy Azure OpenAI Resources

The deployment script creates an Azure OpenAI account and model deployment. Available in both Bash and PowerShell:

**Using Bash (Linux/macOS/WSL):**

```bash
# Make the script executable
chmod +x infra/scripts/deploy_infra.sh

# Deploy with default values
./infra/scripts/deploy_infra.sh

# Or customize the deployment
./infra/scripts/deploy_infra.sh \
  -g my-resource-group \
  -n my-openai-account \
  -l eastus \
  -d gpt-4-deployment \
  -m gpt-4

# View all options
./infra/scripts/deploy_infra.sh --help
```

**Using PowerShell (Windows/Linux/macOS):**

```powershell
# Deploy with default values
./infra/scripts/Deploy-Infra.ps1

# Or customize the deployment
./infra/scripts/Deploy-Infra.ps1 `
  -ResourceGroup "my-resource-group" `
  -AccountName "my-openai-account" `
  -Location "eastus" `
  -DeploymentName "gpt-4-deployment" `
  -ModelName "gpt-4"

# View all options
./infra/scripts/Deploy-Infra.ps1 -Help
```

### Deployment Options

| Option | Environment Variable | Default | Description |
|--------|---------------------|---------|-------------|
| `-g, --resource-group` / `-ResourceGroup` | `RESOURCE_GROUP` | `rg-default` | Azure resource group name |
| `-l, --location` / `-Location` | `LOCATION` | `GermanyWestCentral` | Azure region |
| `-n, --account-name` / `-AccountName` | `ACCOUNT_NAME` | `llm-oai` | OpenAI account name |
| `-d, --deployment-name` / `-DeploymentName` | `DEPLOYMENT_NAME` | `gpt-4o-mini-deployment` | Model deployment name |
| `-m, --model-name` / `-ModelName` | `MODEL_NAME` | `gpt-4o-mini` | OpenAI model to deploy |
| `-v, --model-version` / `-ModelVersion` | `MODEL_VERSION` | `2024-07-18` | Model version |
| `-s, --sku` / `-Sku` | `SKU` | `S0` | SKU tier |
| `-c, --capacity` / `-SkuCapacity` | `SKU_CAPACITY` | `1` | SKU capacity |

After deployment completes, the script will output the environment variables you need to set.

### Deploy with Terraform

For infrastructure as code approach, you can use Terraform:

**Prerequisites:**
1. [Install Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0)
2. Azure CLI logged in (`az login`)
3. Set your Azure subscription:
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

**Find your subscription ID:**
```bash
az account show --query id -o tsv
```

**Deploy:**

1. Navigate to the Terraform directory:
```bash
cd infra/terraform
```

2. Create a `terraform.tfvars` file with your values:
```hcl
resource_group_name        = "rg-openai-dev"
location                   = "GermanyWestCentral"
cognitive_account_name     = "my-openai-account"
cognitive_account_kind     = "OpenAI"
cognitive_account_sku_name = "S0"
cognitive_deployment_name  = "gpt-4o-mini-deployment"
create_resource_group      = true  # Set to false to use existing RG

# Optional - override model defaults
model = {
  format  = "OpenAI"
  name    = "gpt-4o-mini"
  version = "2024-07-18"
}
```

3. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

4. Get output values (including sensitive data):
```bash
# View all outputs
terraform output

# Get specific output (like API endpoint)
terraform output cognitive_account_endpoint

# Get sensitive output (API key)
terraform output -raw cognitive_account_primary_key
```

5. Set environment variables from outputs:
```bash
export AZURE_OPENAI_ENDPOINT=$(terraform output -raw cognitive_account_endpoint)
export AZURE_OPENAI_KEY=$(terraform output -raw cognitive_account_primary_key)
export AZURE_OPENAI_DEPLOYMENT=$(terraform output -raw deployment_name)
export AZURE_OPENAI_API_VERSION="2024-02-15-preview"
```

**To destroy resources:**
```bash
terraform destroy
```

## Configuration

Set the following environment variables:

```bash
export AZURE_OPENAI_ENDPOINT="https://your-region.api.cognitive.microsoft.com"
export AZURE_OPENAI_KEY="your-api-key"
export AZURE_OPENAI_DEPLOYMENT="your-deployment-name"
export AZURE_OPENAI_API_VERSION="2024-02-15-preview"  # Optional, defaults to 2024-02-15-preview
```

### Finding Your Azure OpenAI Values

- **AZURE_OPENAI_ENDPOINT**: Your Azure OpenAI resource endpoint (e.g., `https://germanywestcentral.api.cognitive.microsoft.com`)
- **AZURE_OPENAI_KEY**: Found in Azure Portal → Your OpenAI Resource → Keys and Endpoint
- **AZURE_OPENAI_DEPLOYMENT**: The name of your deployed model (e.g., `gpt-4o-mini-deployment`)
- **AZURE_OPENAI_API_VERSION**: API version to use (optional)

## Usage

Run the chat command:

```bash
./llm_cli chat
```

Or run directly with Go:

```bash
go run main.go chat
```

### Interactive Session

1. **Enter system prompt**: Define the behavior/context for the LLM (e.g., "You are a helpful coding assistant")
2. **Start chatting**: Type your messages at the `>` prompt
3. **Exit**: Type `quit` or `exit`, or press `Ctrl+C`

### Example Session

```
$ ./llm_cli chat
Enter system prompt for LLM context: You are a concise Python expert
System prompt received. Entering chat mode...
> How do I read a JSON file in Python?

Use the `json` module:

```python
import json

with open('file.json', 'r') as f:
    data = json.load(f)
```text

> exit
Exiting...
```

## Project Structure

```text
.
├── cmd/
│   ├── chat.go       # Chat command implementation
│   └── root.go       # Root command setup
├── infra/
│   ├── scripts/
│   │   ├── deploy_infra.sh         # Azure deployment script (Bash)
│   │   └── Deploy-Infra.ps1        # Azure deployment script (PowerShell)
│   └── terraform/
│       ├── azure-openai-service.tf # Terraform resources
│       ├── variables.tf             # Input variables
│       ├── outputs.tf               # Output values
│       └── providers.tf             # Provider configuration
├── main.go           # Application entry point
├── go.mod            # Go module dependencies
├── go.sum            # Dependency checksums
└── README.md
```

## Dependencies

- [github.com/spf13/cobra](https://github.com/spf13/cobra) - CLI framework
- [github.com/openai/openai-go/v3](https://github.com/openai/openai-go) - OpenAI Go SDK
- [github.com/Azure/azure-sdk-for-go/sdk/ai/azopenai](https://github.com/Azure/azure-sdk-for-go) - Azure OpenAI SDK
