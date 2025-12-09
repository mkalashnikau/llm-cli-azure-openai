package cmd

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/Azure/azure-sdk-for-go/sdk/ai/azopenai"
	"github.com/openai/openai-go/v3"
	"github.com/openai/openai-go/v3/option"
	"github.com/spf13/cobra"
)

var chatCmd = &cobra.Command{
	Use:   "chat",
	Short: "LLM chat bot CLI",
	Long:  `LLM chatbot CLI application with Azure OpenAI service`,
	Run: func(cmd *cobra.Command, args []string) {
		azureOpenAIEndpoint := os.Getenv("AZURE_OPENAI_ENDPOINT")
		azureOpenAIKey := os.Getenv("AZURE_OPENAI_KEY")
		deploymentName := os.Getenv("AZURE_OPENAI_DEPLOYMENT")
		apiVersion := os.Getenv("AZURE_OPENAI_API_VERSION")

		if apiVersion == "" {
			apiVersion = "2024-02-15-preview"
		}

		if azureOpenAIEndpoint == "" || azureOpenAIKey == "" || deploymentName == "" {
			log.Fatal("Required environment variables not set: AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_KEY, AZURE_OPENAI_DEPLOYMENT")
		}

		reader := bufio.NewReader(os.Stdin)

		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

		go func() {
			<-sigChan
			fmt.Println("\nInterrupt signal received. Exiting...")
			os.Exit(0)
		}()

		// Azure OpenAI base URL format: https://<resource>.openai.azure.com
		// or regional: https://<region>.api.cognitive.microsoft.com
		baseURL := fmt.Sprintf("%s/openai/deployments/%s", azureOpenAIEndpoint, deploymentName)

		client := openai.NewClient(
			option.WithAPIKey(azureOpenAIKey),
			option.WithBaseURL(baseURL),
			option.WithHeader("api-key", azureOpenAIKey),
			option.WithQuery("api-version", apiVersion),
		)

		ctx := context.Background()

		fmt.Print("Enter initial prompt for LLM: ")
		initialPrompt, _ := reader.ReadString('\n')
		initialPrompt = strings.TrimSpace(initialPrompt)

		messages := []openai.ChatCompletionMessageParamUnion{
			openai.SystemMessage(initialPrompt),
		}
		fmt.Println("Initial prompt received. Entering chat mode...")

		for {
			fmt.Print("> ")
			input, _ := reader.ReadString('\n')
			input = strings.TrimSpace(input)

			switch input {
			case "quit", "exit":
				fmt.Println("Exiting...")
				os.Exit(0)
			default:
				messages = append(messages, openai.UserMessage(input))

				stream := client.Chat.Completions.NewStreaming(ctx, openai.ChatCompletionNewParams{
					Model:     openai.ChatModel(deploymentName),
					Messages:  messages,
					MaxTokens: openai.Int(1024),
				})

				defer stream.Close()

				response := ""
				for stream.Next() {
					chunk := azopenai.ChatCompletionChunk(stream.Current())

					if len(chunk.Choices) > 0 && chunk.Choices[0].Delta.Content != "" {
						content := chunk.Choices[0].Delta.Content
						fmt.Print(content)
						response += content
					}
				}

				if err := stream.Err(); err != nil {
					log.Printf("Error: %v\n", err)
					continue
				}

				fmt.Println()
				messages = append(messages, openai.AssistantMessage(response))
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(chatCmd)
}
