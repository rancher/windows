locals {
  prefix = trim(var.group, "-")

  ssh_public_key = file(var.ssh_public_key_path)
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}