data "azurerm_storage_account" "account" {
  name                = var.storage_account
  resource_group_name = var.resource_group
}