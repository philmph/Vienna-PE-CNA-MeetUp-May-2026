locals {
  region = "westeurope"
}

data "azurerm_client_config" "current" {}

resource "random_string" "this" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_resource_group" "this" {
  name     = "rg-ephemeral-resources"
  location = local.region

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_key_vault" "this" {
  name                       = "kv${random_string.this.result}"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  rbac_authorization_enabled = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# write path: value_wo — never written to state
resource "azurerm_key_vault_secret" "this" {
  name             = "write-only-secret"
  key_vault_id     = azurerm_key_vault.this.id
  value_wo         = var.secret_value
  value_wo_version = var.secret_version

  depends_on = [azurerm_role_assignment.this]
}

# Step 2: uncomment — read path via ephemeral resource, never written to state
# ephemeral "azurerm_key_vault_secret" "ephemeral" {
#   name         = "write-only-secret"
#   key_vault_id = azurerm_key_vault.this.id

#   depends_on = [azurerm_role_assignment.this, azurerm_key_vault_secret.this]
# }

# Step 3: comment out Step 2 block, uncomment — read path via data source, value written to state
# data "azurerm_key_vault_secret" "non_ephemeral" {
#   name         = "write-only-secret"
#   key_vault_id = azurerm_key_vault.this.id

#   depends_on = [azurerm_role_assignment.this, azurerm_key_vault_secret.this]
# }
