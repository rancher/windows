resource "azurerm_storage_container" "container" {
  name                 = var.storage_container
  storage_account_name = var.storage_account
}

resource "azurerm_storage_blob" "blobs" {
  for_each = var.blobs

  name                   = each.key
  storage_account_name   = var.storage_account
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source_content         = each.value
}

locals {
  generated_storage_blobs = zipmap(
    keys(var.blobs),
    values(azurerm_storage_blob.blobs)
  )
}

output "storage" {
  value = {
    container = azurerm_storage_container.container
    blobs     = local.generated_storage_blobs
  }
}
