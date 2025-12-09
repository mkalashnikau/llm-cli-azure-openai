output "cognitive_account_id" {
  value = azurerm_cognitive_account.this.id
}

output "cognitive_account_endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}

output "cognitive_accoint_primary_key" {
  sensitive = true
  value = azurerm_cognitive_account.this.primary_access_key
}