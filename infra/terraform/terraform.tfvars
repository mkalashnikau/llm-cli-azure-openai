resource_group_name       = "rg-openai-dev"
location                  = "GermanyWestCentral"
cognitive_account_name    = "llm-oai"
cognitive_account_kind    = "OpenAI"
cognitive_account_sku_name = "S0"
cognitive_deployment_name  = "gpt-4o-mini-deployment"
create_resource_group     = true

# Optional - uses defaults if omitted
model = {
  format  = "OpenAI"
  name    = "gpt-4o-mini"
  version = "2024-07-18"
}