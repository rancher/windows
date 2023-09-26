data "azurerm_virtual_network" "vnets" {
  for_each = var.peers

  name = each.key
  # The assumption is that the vnet will exist in a resource group with the same name
  # This simplifies the inputs of the Terraform module.
  # Feel free to change this if this expectation changes over time.
  resource_group_name = each.value.resource_group != null ? each.value.resource_group : each.key
}

locals {
  identified_vnet_peers = zipmap(keys(var.peers), values(data.azurerm_virtual_network.vnets))
}

resource "azurerm_virtual_network_peering" "to-remote" {
  for_each = local.identified_vnet_peers

  name                      = "${azurerm_virtual_network.vnet.name}-to-${each.key}"
  resource_group_name       = var.resource_group
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = each.value.id
}

resource "azurerm_virtual_network_peering" "from-remote" {
  for_each = local.identified_vnet_peers

  name = "${each.key}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name = lookup(lookup(var.peers, each.value.name, {
    resource_group = null
  }), "resource_group", each.value.name) == null ? each.value.name : var.peers[each.value.name].resource_group
  virtual_network_name      = each.value.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}
