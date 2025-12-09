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

The deployment script creates an Azure OpenAI account and model deployment:

```bash
# Make the script executable
chmod +x infra/deploy_azure_infra.sh

# Deploy with default values
./infra/deploy_azure_infra.sh

# Or customize the deployment
./infra/deploy_azure_infra.sh \
  -g my-resource-group \
  -n my-openai-account \
  -l eastus \
  -d gpt-4-deployment \
  -m gpt-4

# View all options
./infra/deploy_azure_infra.sh --help
```

### Deployment Options

| Option | Environment Variable | Default | Description |
|--------|---------------------|---------|-------------|
| `-g, --resource-group` | `RESOURCE_GROUP` | `rg-default` | Azure resource group name |
| `-l, --location` | `LOCATION` | `GermanyWestCentral` | Azure region |
| `-n, --account-name` | `ACCOUNT_NAME` | `llm-oai` | OpenAI account name |
| `-d, --deployment-name` | `DEPLOYMENT_NAME` | `gpt-4o-mini-deployment` | Model deployment name |
| `-m, --model-name` | `MODEL_NAME` | `gpt-4o-mini` | OpenAI model to deploy |
| `-v, --model-version` | `MODEL_VERSION` | `2024-07-18` | Model version |
| `-s, --sku` | `SKU` | `S0` | SKU tier |
| `-c, --capacity` | `SKU_CAPACITY` | `1` | SKU capacity |

After deployment completes, the script will output the environment variables you need to set.

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
│   └── deploy_azure_infra.sh  # Azure infrastructure deployment script
├── main.go           # Application entry point
├── go.mod            # Go module dependencies
├── go.sum            # Dependency checksums
└── README.md
```

## Dependencies

- [github.com/spf13/cobra](https://github.com/spf13/cobra) - CLI framework
- [github.com/openai/openai-go/v3](https://github.com/openai/openai-go) - OpenAI Go SDK
- [github.com/Azure/azure-sdk-for-go/sdk/ai/azopenai](https://github.com/Azure/azure-sdk-for-go) - Azure OpenAI SDK
