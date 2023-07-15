resource "azurerm_storage_account" "storage_account" {
  name                = var.storage_account
  location            = var.location
  resource_group_name = var.resource_group

  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [tags]
  }
}


output "storage" {
  value = {
    account = azurerm_storage_account.storage_account
  }
}
