output "key_vault_name" {
  description = "Name of the Key Vault (random suffix)."
  value       = azurerm_key_vault.this.name
}
