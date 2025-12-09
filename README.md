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
- Azure OpenAI resource with a deployed model
- API key for your Azure OpenAI resource

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
├── main.go           # Application entry point
├── go.mod            # Go module dependencies
├── go.sum            # Dependency checksums
└── README.md
```

## Dependencies

- [github.com/spf13/cobra](https://github.com/spf13/cobra) - CLI framework
- [github.com/openai/openai-go/v3](https://github.com/openai/openai-go) - OpenAI Go SDK
- [github.com/Azure/azure-sdk-for-go/sdk/ai/azopenai](https://github.com/Azure/azure-sdk-for-go) - Azure OpenAI SDK
