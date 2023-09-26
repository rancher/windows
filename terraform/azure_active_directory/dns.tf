resource "azurerm_private_dns_zone" "dns_zone" {
  name                = local.active_directory_domain
  resource_group_name = var.name

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [module.server]
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = var.name
  resource_group_name   = var.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = module.server.network.vpc.id

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_a_record" "dns_record" {
  name                = var.name
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = var.name
  ttl                 = 300
  records             = [module.server.machines[var.name].private_ip]
}
