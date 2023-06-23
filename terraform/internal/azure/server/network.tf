module "network" {
  source = "../../network"

  type = var.network.simple.enabled ? "simple" : var.network.template
  airgap = false
  open_ports = var.network.simple.enabled ? var.network.simple.open_ports : []
}

locals {
  vpc = module.network.vpc
  subnets = module.network.subnets
  rules = [
    for i, v in module.network.rules :
    merge(v, {
      name                         = "${rule.value.action}-${rule.value.name}"
      description                  = "${rule.value.description}"
      access                       = title(rule.value.action)
      direction                    = title(rule.value.direction)
      
      source_port_range            = "*"
      destination_port_range       = rule.port_range
      
      source_address_prefix        = rule.from == ["*"] ? "*" : null
      destination_address_prefix   = rule.to == ["*"] ? "*" : null
      source_address_prefixes      = rule.from != ["*"] ? rule.from : null
      destination_address_prefixes = rule.to != ["*"] ? rule.to : null
      
      protocol                     = title(rule.value.protocol)
      priority                     = 4096 - i
    })
  ]
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [local.vpc.address_space]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "rule" {
    for_each = local.rules

    content {
      name                         = rule.value.name
      description                  = rule.value.description
      access                       = rule.value.access
      direction                    = rule.value.direction
      source_port_range            = rule.value.source_port_range
      destination_port_range       = rule.value.destination_port_range
      destination_port_ranges      = rule.value.destination_port_ranges
      source_address_prefix        = rule.value.source_address_prefix
      destination_address_prefix   = rule.value.destination_address_prefix
      source_address_prefixes      = rule.value.source_address_prefixes
      destination_address_prefixes = rule.value.destination_address_prefixes
      protocol                     = rule.value.protocol
      priority                     = rule.value.priority
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets

  name                 = "${local.prefix}-${each.key}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name

  address_prefixes = [each.value]
}

resource "azurerm_subnet_network_security_group_association" "subnet_to_nsg" {
  for_each = local.subnets

  subnet_id                 = local.generated_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

locals {
  generated_subnets = zipmap(keys(local.subnets), values(azurerm_subnet.subnets))
}
