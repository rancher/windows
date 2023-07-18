resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

output "resource_group" {
  value = azurerm_resource_group.rg
}
