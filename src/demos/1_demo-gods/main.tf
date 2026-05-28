resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "this" {
  name               = "memes"
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_blob" "this" {
  name                   = "meme-cat.jpeg"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "${path.module}/data/meme-cat.jpeg"
}

resource "azurerm_storage_blob" "phishing" {
  name                   = "phishing-qr.jpg"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "${path.module}/data/phishing-qr.jpg"
}
