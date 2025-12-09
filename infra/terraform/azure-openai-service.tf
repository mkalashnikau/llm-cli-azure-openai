resource "azurerm_resource_group" "rg" {
  count = var.create_resource_group ? 1 : 0
  
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  
  name = var.resource_group_name
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.existing[0].name
  location            = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.existing[0].location
}

resource "azurerm_cognitive_account" "this" {
  name                = var.cognitive_account_name
  location            = local.location
  resource_group_name = local.resource_group_name
  kind                = var.cognitive_account_kind
  sku_name            = var.cognitive_account_sku_name

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_cognitive_deployment" "this" {
  name                 = var.cognitive_deployment_name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = var.model.format
    name    = var.model.name
    version = var.model.version
  }

  sku {
    name = var.cognitive_deployment_sku
  }
}
